#!/bin/sh
#  c_rehash bash for webos using busybox
#  requires cleancerts.sh verifylinks.sh in same dir
#  cleans expired certs, makes sure evey pem has a hash symlink

OPENSSL=/usr/bin/openssl
DIR=/etc/ssl/certs/trustedcerts
LINKDIR=/var/ssl/trustedcerts
VARDIR=/var/ssl/certs

if [ ! -x ${OPENSSL} ]; then
  echo "c-rehash-bash: rehashing skipped ('openssl' program not available)\n"
  exit
fi

if [ $# -gt 0 ]; then
 if [ -n "$1" ] && [ -d "$1" ]; then
   DIR="$1"
 fi
 if [ -n "$2" ] && [ -d "$2" ]; then
   LINKDIR="$2"
 fi
fi

if [ -L "${LINKDIR}" ] || [ -L "${DIR}" ]; then
    echo "${DIR} or ${LINKDIR} is a symlink, will not rehash files"
    exit 1
fi

if [ ! -d "${DIR}" ] ; then
    echo "${DIR} is a not a directory, will not rehash files"
    exit 1
fi

# cleanup expired certs
echo "checking ${DIR} for expired certs"
./cleancerts.sh ${DIR}

if [ ! -L "${VARDIR}" ] && [ -d "${VARDIR}" ] ; then
  echo "checking ${VARDIR} for expired certs"
  ./cleancerts.sh ${VARDIR}
  echo "removing any dead sym links in ${VARDIR}"
  find ${VARDIR} -follow -type l -delete
  echo "verifying sym links in ${VARDIR}"
  ./verifylinks.sh ${VARDIR}
fi

# remove any deadend hash symlinks
echo "removing any dead sym links in ${LINKDIR}"
find ${LINKDIR} -follow -type l -delete
echo "removing any dead sym links in ${DIR}"
find ${DIR} -follow -type l -delete

echo "verifying sym links in ${DIR}"
# check hash links values
# leave trailing back slash off of directories
# i.e.  /var/ssl/trustedcerts
./verifylinks.sh ${DIR}
echo "verifying sym links in ${LINKDIR}"
./verifylinks.sh ${DIR} ${LINKDIR}

# not used line below creates a bundle of the installed certs
#find /etc/ssl/certs/trustedcerts -type f -print0 -name *.pem  | xargs -0  sed -n '/-----BEGIN/,/END CERTIFICATE-----/p' >> /usr/lib/ssl/cert.pem
