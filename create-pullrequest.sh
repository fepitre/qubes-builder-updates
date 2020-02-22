#!/bin/bash

set -e
if [ "${VERBOSE:-0}" -ge 2 ] || [ "${DEBUG:-0}" -eq 1 ]; then
    set -x
fi

skip_remove() {
    rm -rf "$GIT_SRC/.skip"
}

GIT_SRC="$(readlink -f "$1")"
GIT_BASE="${2:-QubesOS}"
GIT_BASE_BRANCH="${3:-master}"
GIT_UPDATE="${4:-fepitre-bot}"
GIT_BASEURL_UPDATE="${5:-git@github.com:}"
GIT_PREFIX_UPDATE="${6:-$GIT_UPDATE/qubes-}"

if [ -d "$GIT_SRC" ]; then
    trap 'skip_remove' 0 1 2 3 6 15
    cd "${GIT_SRC}"
    COMPONENT="$(basename "$(git remote -v | head -1 | awk '{print $2}')")"
    COMPONENT="${COMPONENT//qubes-}"
    VERSION="$(cat version)"
    GIT_UPDATE_BRANCH="update-v$VERSION"
    GIT_PULLREQUEST_TITLE="UPDATE: $VERSION"

	if ! { hub pr list -f '%t%n' | grep "$GIT_PULLREQUEST_TITLE"; }; then \
        # In qubes-infrastructure build vms, the remote will be set at
        # the first build so skip if sources are not removed
		git remote add "$GIT_UPDATE" "${GIT_BASEURL_UPDATE}${GIT_PREFIX_UPDATE}${COMPONENT}" || true; \
		git push -u "$GIT_UPDATE" "$GIT_UPDATE_BRANCH"; \
		hub pull-request -m "$GIT_PR_TITLE" --base "${GIT_BASE}:${GIT_BASE_BRANCH}" --head "${GIT_UPDATE}:${GIT_UPDATE_BRANCH}"; \
	fi;
fi