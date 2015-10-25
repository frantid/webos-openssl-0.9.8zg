NAME     = openssl
TITLE	 = OpenSSL
APP_ID   = com.palm.${NAME}
SRC_VER  = 0.9.8zg
VERSION  = 0.9.8.1-1

SRC_TGZ = http://www.openssl.org/source/openssl-${SRC_VER}.tar.gz

DESCRIPTION = Openssl update to latest stable version.  Adds new root certificates and performs maintenance on existing certificates.
CHANGELOG = \
0.9.8.1-1: Initial version openssl.vg
HOMEPAGE = http://www.openssl.org/
TYPE	 = Utilities
CATEGORY = Libraries
POSTINSTALLFLAGS = RestartDevice
ICON	 = http://www.webos-internals.org/images/a/ae/Icon_WebOSInternals_OpenSSL.png


.PHONY: package
package: ipkgs/${APP_ID}_${VERSION}_armv7.ipk ipkgs/${APP_ID}_${VERSION}_armv6.ipk ipkgs/${APP_ID}_${VERSION}_i686.ipk
include ../../support/package.mk

include ../../support/download.mk

.PHONY: unpack
unpack: build/.unpacked-${VERSION}

build/.unpacked-${VERSION}: ${DL_DIR}/${NAME}-${VERSION}.tar.gz
	rm -rf build
	mkdir -p build/armv6 build/armv7 build/i686
	tar -C build -xf ${DL_DIR}/${NAME}-${VERSION}.tar.gz
	mv build/${NAME}-${SRC_VER} build/src
	cp -f addfiles/s_client.c build/src/apps/s_client.c
	cp -f addfiles/s_time.c build/src/apps/s_time.c
	cp -f addfiles/cryptlib.h build/src/crypto/cryptlib.h
	cp -f addfiles/ssl_lib.c build/src/ssl/ssl_lib.c
	touch $@

.PHONY: build
build: build/.built-${VERSION}

build/.built-${VERSION}: build/armv7.built-${VERSION} build/armv6.built-${VERSION} build/i686.built-${VERSION}
	touch $@

include ../../support/cross-compile.mk

build/%.built-${VERSION}: build/.unpacked-${VERSION}
	rm -rf build/$*
	( cd build/src ; \
	  CC=${CROSS_COMPILE_$*}gcc \
	  ./Configure shared no-zlib no-asm linux-elf --prefix=/usr --openssldir=/usr/lib/ssl; \
	  ${MAKE} \
		AR="${CROSS_COMPILE_$*}ar r" RANLIB=${CROSS_COMPILE_$*}ranlib \
		clean all )
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/addfiles
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/addfiles/scripts
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/usr/bin
	mkdir -p build/$*/usr/palm/applications/${APP_ID}/usr/lib
	install -m 755 build/src/apps/openssl build/$*/usr/palm/applications/${APP_ID}/usr/bin/
	install -m 755 addfiles/openssl.cnf build/$*/usr/palm/applications/${APP_ID}/usr/bin/
	install -m 755 build/src/libcrypto.so.0.9.8 build/$*/usr/palm/applications/${APP_ID}/usr/lib/
	install -m 755 build/src/libssl.so.0.9.8 build/$*/usr/palm/applications/${APP_ID}/usr/lib/
	install -m 755 addfiles/scripts/* build/$*/usr/palm/applications/${APP_ID}/addfiles/scripts/
	touch $@

clobber::
	rm -rf build

