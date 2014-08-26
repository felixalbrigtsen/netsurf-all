#!/bin/make
#
# NetSurf Source makefile for libraries and browser

# Component settings
COMPONENT := netsurf-all
COMPONENT_VERSION := 3.2

# Targets

# Netsurf target
NETSURF_TARG := netsurf

# nsgenbind host tool
NSGENBIND_TARG := nsgenbind

# Library targets
NSLIB_ALL_TARG := buildsystem libwapcaplet libparserutils libcss libhubbub libdom libnsbmp libnsgif librosprite

NSLIB_SVGTINY_TARG := libsvgtiny

NSLIB_FB_TARG := libnsfb

NSLIB_RO_TARG := librufl libpencil


# Build Environment
export TARGET ?= gtk
TMP_PREFIX := $(CURDIR)/inst-$(TARGET)
export PKG_CONFIG_PATH = $(TMP_PREFIX)/lib/pkgconfig
export PATH := $(PATH):$(TMP_PREFIX)/bin/
HOST := $(shell uname -s)
TMP_NSSHARED := $(CURDIR)/buildsystem


# only build what we require for the target
ifeq ($(TARGET),riscos)
  NSLIB_TARG := $(NSLIB_ALL_TARG) $(NSLIB_SVGTINY_TARG) $(NSLIB_RO_TARG)
  NSHOST_TARG := $(NSGENBIND_TARG)
else
  ifeq ($(TARGET),framebuffer)
    NSLIB_TARG := $(NSLIB_ALL_TARG) $(NSLIB_SVGTINY_TARG)  $(NSLIB_FB_TARG)
    NSHOST_TARG := $(NSGENBIND_TARG)
  else
    ifeq ($(TARGET),amiga)
      NSLIB_TARG := $(NSLIB_ALL_TARG) $(NSLIB_SVGTINY_TARG)
      NSHOST_TARG := $(NSGENBIND_TARG)
      NETSURF_CONFIG := NETSURF_USE_MOZJS=YES
    else
      ifeq ($(TARGET),cocoa)
        NSLIB_TARG := $(NSLIB_ALL_TARG) $(NSLIB_SVGTINY_TARG) 
	export CFLAGS := -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -Wno-error
      else
        ifeq ($(TARGET),atari)
          NSLIB_TARG := $(NSLIB_ALL_TARG)
          NSHOST_TARG := $(NSGENBIND_TARG)
        else
          NSLIB_TARG := $(NSLIB_ALL_TARG) $(NSLIB_SVGTINY_TARG) 
          NSHOST_TARG := $(NSGENBIND_TARG)
        endif
      endif
    endif
  endif
endif

.PHONY: build install clean release-checkout head-checkout dist

# clean macro for each sub target
define do_clean
	$(MAKE) distclean --directory=$1 TARGET=$(TARGET) NSSHARED=$(TMP_NSSHARED)

endef

# clean macro for each host sub target
define do_host_clean
	$(MAKE) distclean --directory=$1 TARGET=$(HOST) NSSHARED=$(TMP_NSSHARED)

endef

# prefixed install macro for each sub target
define do_prefix_install
	$(MAKE) install --directory=$1 TARGET=$(TARGET) PREFIX=$(TMP_PREFIX) DESTDIR=

endef

# prefixed install macro for each host sub target
define do_host_prefix_install
	$(MAKE) install --directory=$1 TARGET=$(HOST) PREFIX=$(TMP_PREFIX) DESTDIR=

endef

build: $(TMP_PREFIX)/build-stamp

$(TMP_PREFIX)/build-stamp:
	mkdir -p $(TMP_PREFIX)/include
	mkdir -p $(TMP_PREFIX)/lib
	mkdir -p $(TMP_PREFIX)/bin
	$(foreach L,$(NSLIB_TARG),$(call do_prefix_install,$(L)))
	$(foreach L,$(NSHOST_TARG),$(call do_prefix_install,$(L)))
	$(MAKE) --directory=$(NETSURF_TARG) PREFIX=$(PREFIX) TARGET=$(TARGET) $(NETSURF_CONFIG)
	touch $@

package: $(TMP_PREFIX)/build-stamp
	$(MAKE) --directory=$(NETSURF_TARG) PREFIX=$(PREFIX) TARGET=$(TARGET) package $(NETSURF_CONFIG)

install: $(TMP_PREFIX)/build-stamp
	$(MAKE) install --directory=$(NETSURF_TARG) TARGET=$(TARGET) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) $(NETSURF_CONFIG)

clean:
	$(RM) -r $(TMP_PREFIX)
	$(foreach L,$(NSLIB_TARG),$(call do_clean,$(L)))
	$(foreach L,$(NSHOST_TARG),$(call do_host_clean,$(L)))
	$(MAKE) clean --directory=$(NETSURF_TARG) TARGET=$(TARGET)

release-checkout: $(NSLIB_TARG) $(NETSURF_TARG) $(NSGENBIND_TARG) $(NSLIB_RO_TARG)
	git pull --recurse-submodules
	for x in $^; do cd $$x; (git checkout origin/HEAD && git checkout $$(git describe --abbrev=0 --match="release/*" )); cd ..; done

head-checkout: $(NSLIB_TARG) $(NETSURF_TARG) $(NSGENBIND_TARG) $(NSLIB_RO_TARG)
	git pull --recurse-submodules
	for x in $^; do cd $$x; git checkout origin/HEAD ; cd ..; done

dist:
	$(eval GIT_TAG := $(shell git describe --abbrev=0 --match "release/*"))
	$(eval GIT_VER := $(shell x="$(GIT_TAG)"; echo "$${x#release/}"))
	$(if $(subst $(GIT_VER),,$(COMPONENT_VERSION)), $(error Component Version "$(COMPONENT_VERSION)" and GIT tag version "$(GIT_VER)" do not match))
	$(eval DIST_FILE := $(COMPONENT)-${GIT_VER})
	$(Q)git-archive-all --force-submodules --prefix=$(DIST_FILE)/ $(DIST_FILE).tgz
	$(Q)mv $(DIST_FILE).tgz $(DIST_FILE).tar.gz
