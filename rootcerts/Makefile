NAME     = rootcertsupdate
TITLE	 = RootCertsUpdate
APP_ID   = com.palm.${NAME}
VERSION  = 1.0-1


DESCRIPTION = Adds new root certificates and performs maintenance on existing certificates.
CHANGELOG = \
1.0-1: Initial version
HOMEPAGE = https://github.com/frantid/webos-openssl-0.9.8zg/tree/master/rootcerts
TYPE	 = Utilities
CATEGORY = Libraries
ICON	 = http://www.webos-internals.org/images/e/ec/Icon_Box_Cog.png

.PHONY: package
package: ipkgs/${APP_ID}_${VERSION}_all.ipk
include ../../support/package.mk

.PHONY: unpack
unpack: build/.unpacked-${VERSION}

build/.unpacked-${VERSION}:
	rm -rf build
	mkdir -p build
	cd build
	touch $@

.PHONY: build
build: build/.built-${VERSION}

build/.built-${VERSION}: build/all.built-${VERSION}
	touch $@


build/%.built-${VERSION}: build/.unpacked-${VERSION}
	rm -rf build/$*
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/scripts
	install -m 755 scripts/* build/$*/usr/palm/applications/${APP_ID}/scripts/
	touch $@

clobber::
	rm -rf build

