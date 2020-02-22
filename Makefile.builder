ifeq ($(DISTRIBUTION),)
    $(warning This plugin must be loaded after distribution-specifc one)
else ifneq (,$(findstring $(DISTRIBUTION), debian qubuntu fedora centos))
    BUILDER_UPDATES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
    BUILDER_MAKEFILE += $(BUILDER_UPDATES_DIR)/Makefile.updates
else
    $(error Distribution $(DISTRIBUTION) not supported by builder-updates plugin)
endif

# vim: ft=make
