#!/bin/bash

set -e
if [ "${VERBOSE:-0}" -ge 2 ] || [ "${DEBUG:-0}" -eq 1 ]; then
    set -x
fi

GIT_SRC="$(readlink -f "$1")"
GIT_BASE_BRANCH="$2"

exit_update() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        touch "$GIT_SRC/.skip_update"
    fi
    exit 0
}

trap 'exit_update' 0 1 2 3 6 15
if [ -d "$GIT_SRC" ]; then
    cd "${GIT_SRC}"
    # Check if update-sources exists
    make -n update-sources >/dev/null 2>&1; 
    # TODO: This plugin should not be used in dev env
    # we stash (backup) any current work/modifications.
    # Maybe backup to temporary branch?
    git stash
    git checkout "$GIT_BASE_BRANCH"
    make update-sources
    # We assume that update-sources target will change
    # at least version file
    COMPONENT="$(basename "$(git remote -v | head -1 | awk '{print $2}')")"
    COMPONENT="${COMPONENT//qubes-}"
    if [ -n "$(git diff version)" ]; then
        VERSION="$(cat version)"
        GIT_UPDATE_BRANCH="update-v$VERSION"
        # In case of previous build failed
        # we delete existing update branch
        git branch -D "$GIT_UPDATE_BRANCH" || true
        git checkout -b "$GIT_UPDATE_BRANCH"
        echo 1 > rel
        # Add only tracked files and ignore untracked
        git add -u
        git commit -m "Update to $COMPONENT-$VERSION"
    fi
fi