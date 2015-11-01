NAME     = rootcertsupdate
TITLE	 = RootCertsUpdate
APP_ID   = com.palm.${NAME}
VERSION  = 1.0-1
MAINTAINER = frantid <http://forums.precentral.net/members/frantid.html>
CATEGORY = misc
PRIORITY = optional

.PHONY: package
package: ipkgs/${APP_ID}_${VERSION}_all.ipk

ipkgs/${APP_ID}_${VERSION}_%.ipk: build/.built-${VERSION}
	rm -f ipkgs/${APP_ID}_${VERSION}_$*.ipk
	rm -f build/$*/CONTROL/control
	${MAKE} build/$*/CONTROL/control
	rm -f build/$*/CONTROL/postinst
	${MAKE} build/$*/CONTROL/postinst
	rm -f build/$*/CONTROL/prerm
	${MAKE} build/$*/CONTROL/prerm
	mkdir -p ipkgs
	  ( cd build ; \
	    TAR_OPTIONS="--wildcards --mode=g-s" \
	    ../../../toolchain/ipkg-utils/ipkg-build -o 0 -g 0 ${BLDFLAGS} $* )
	mv build/${APP_ID}_${VERSION}_$*.ipk $@

build/%/CONTROL/postinst:
	if [ -e control/postinst ] ; then \
	  install -m 755 control/postinst $@ ; \
	fi

build/%/CONTROL/prerm:
	if [ -e control/prerm ] ; then \
	  install -m 755 control/prerm $@ ; \
	fi

build/%/CONTROL/control: /dev/null
	rm -f $@
	mkdir -p build/$*/CONTROL
	echo "Package: ${APP_ID}" > $@
	/bin/echo -n "Version: " >> $@
	echo "${VERSION}" >> $@
	echo "Architecture: $*" >> $@
	/bin/echo -n "Maintainer: " >> $@
	echo "${MAINTAINER}" >> $@
	/bin/echo -n "Description: " >> $@
	echo "${TITLE}" >> $@
	echo "Section: ${CATEGORY}" >> $@
	echo "Priority: ${PRIORITY}" >> $@
	/bin/echo -n "Source: " >> $@
	touch $@

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
	rm -rf ipkgs

