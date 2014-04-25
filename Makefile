#!/bin/make
#
# NetSurf Source makefile for libraries and browser

export TARGET ?= gtk
export PKG_CONFIG_PATH = $(TMP_PREFIX)/lib/pkgconfig
TMP_PREFIX := $(CURDIR)/inst-$(TARGET)

NETSURF_TARG := netsurf

NSLIBTARG :=  buildsystem libwapcaplet libparserutils libcss libhubbub libdom libnsbmp libnsgif librosprite libnsfb libsvgtiny nsgenbind

# clean macro for each sub target
define do_clean
	$(MAKE) distclean --directory=$1 TARGET=$(TARGET)
endef

# prefixed install macro for each sub target
define do_prefix_install
	$(MAKE) install --directory=$1 TARGET=$(TARGET) PREFIX=$(TMP_PREFIX) DESTDIR=
endef

.PHONY: build install clean release-checkout

build: $(TMP_PREFIX)/build-stamp

$(TMP_PREFIX)/build-stamp:
	mkdir -p $(TMP_PREFIX)/include
	mkdir -p $(TMP_PREFIX)/lib
	$(foreach L,$(NSLIBTARG),$(call do_prefix_install,$(L)))
	$(MAKE) --directory=$(NETSURF_TARG) PREFIX=$(PREFIX) TARGET=$(TARGET)
	touch $@

install: $(TMP_PREFIX)/build-stamp
	$(MAKE) install --directory=$(NETSURF_TARG) TARGET=$(TARGET) PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)

clean:
	$(RM) -r $(TMP_PREFIX)
	$(foreach L,$(NSLIBTARG),$(call do_clean,$(L)))
	$(MAKE) clean --directory=$(NETSURF_TARG) TARGET=$(TARGET)

release-checkout: $(NSLIBTARG) $(NETSURF_TARG)
	for x in $^; do cd $$x; (git checkout origin/HEAD && git checkout $$(git describe --abbrev=0 --match="release/*" )); cd ..; done
