#!/bin/sh
# Begin make-ca.sh
# modified for webOS the original source is listed below
# source: http://www.linuxfromscratch.org/blfs/view/svn/postlfs/cacerts.html
# Script to populate OpenSSL's CApath from a bundle of PEM formatted CAs
#
# The file certdata.txt must exist in the local directory
# Version number is obtained from the version of the data.
#
# Authors: DJ Lucas
#          Bruce Dubbs
#
# Version 20120211

certdata="ca-certificates.crt"

if [ ! -r ${certdata} ]; then
  echo "$certdata must be in the local directory"
  exit 1
fi

TEMPDIR=$(mktemp -d)
BUNDLE="system-bundle.crt"


COUNT=0
mkdir "${TEMPDIR}/certs"

# Get a list of starting lines for each cert
CERTBEGINLIST=$(grep -n "^subject=" "${certdata}" | cut -d ":" -f 1)

# Get a list of ending lines for each cert
CERTENDLIST=`grep -n "^-----END CERTIFICATE-----" "${certdata}" | cut -d ":" -f 1`

# Start a loop
for certbegin in ${CERTBEGINLIST}; do
  for certend in ${CERTENDLIST}; do
    if test "${certend}" -gt "${certbegin}"; then
      break
    fi
  done

  # Dump to a temp file with the name of the file as the beginning line number
  sed -n "${certbegin},${certend}p" "${certdata}" > "${TEMPDIR}/certs/${certbegin}.tmp"
done

unset CERTBEGINLIST CERTDATA CERTENDLIST certbegin certend

mkdir -p precerts
rm -f precerts/*      # Make sure the directory is clean

for tempfile in ${TEMPDIR}/certs/*.tmp; do

  # If execution made it to here in the loop, the temp cert is trusted
  # Find the cert data and generate a cert file for it

  cp "${tempfile}" tempfile.crt
  subject=$(openssl x509 -noout -in tempfile.crt -subject -nameopt oneline)
  subtext=$(echo "${subject}" | sed 's#, #\\#g' | sed 's#subject= #subject=\\#' \
    | sed -r 's/[ ]?//g' )
  fileName=$(openssl x509 -noout -in tempfile.crt -hash)
  num=1
  while [ -e "precerts/${fileName}.pem" ]; do
      fileName="${fileName}_${num}"
      let num=num+1
      if [ $num -gt 6 ]; then
          break
      fi
  done
  mv tempfile.crt "precerts/${fileName}.pem"
  echo "Created ${fileName}.pem ${COUNT}"
  let COUNT=COUNT+1
done

# Remove blacklisted files
# MD5 Collision Proof of Concept CA
if test -f precerts/8f111d69.pem; then
  echo "Certificate 8f111d69 is not trusted!  Removing..."
  rm -f precerts/8f111d69.pem
fi
SRCDIR=certs
TARGETDIR=precerts
./cleancerts.sh precerts
cd certs
CERTS=$(find ./*.pem )
cd ".."
count=1
mcount=0
pc=0
palmCerts=""
for CERT in $CERTS; do
    CERTNAME=""$(echo "${CERT}" | sed -nr  's|^(\.\/)(.*)|\2|p')
    subject=$(openssl x509 -noout -in "${SRCDIR}/${CERTNAME}" -subject -nameopt oneline)
    subtext=$(echo "${subject}" | sed 's#, #/#g' | sed 's#subject= #subject= /#' )
    matchNums=""
    noMatchNum=0
    HASH=$(openssl x509 -noout -in "${SRCDIR}/${CERTNAME}" -hash)
    echo "hash is: ${HASH}"
    if [ -z ${HASH} ]; then
      echo "bad hash for file: ${CERTNAME}"
      continue
    fi
    if [ -e "${TARGETDIR}/${HASH}.pem" ]; then
        FINGER1=$(openssl x509 -in "${SRCDIR}/${CERTNAME}" -fingerprint -noout | sed -r 's/.*Fingerprint=(.*)/\1/'|sed -r 's/://g')
        testfiles=$(find "${TARGETDIR}/" -name "${HASH}*")
        testL=0 #number of matches

        for file in $testfiles; do
            let testL=testL+1
        done
        echo "files matching ${testL}"
        for file in $testfiles; do
             fileNo=$(echo ${file} | sed -n 's/.*_\([0-9]\).pem$/\1/p')
             if [ -z ${fileNo} ]; then
                 fileNo=0
             fi
             FINGER2=$(openssl x509 -noout -in "${file}" -fingerprint | sed -r 's/.*Fingerprint=(.*)/\1/'|sed -r 's/://g')
             if [ $FINGER1 != $FINGER2 ]; then
                echo "${FINGER1} NOT equal ${FINGER2}"
                if [ $fileNo -ge $noMatchNum ]; then
                 noMatchNum=$(($fileNo+1))
                fi
             else
                echo "${FINGER1} Equals ${FINGER2}"
                # echo "breaking"
                matchNums="${file}"
                break
             fi
        done
   fi
   if [ -z ${matchNums} ] && [ -n ${HASH} ] && [ -f ${SRCDIR}/${CERTNAME} ]; then
       echo "${subtext}" > "${TARGETDIR}/${CERTNAME}"
      #
       cat "${SRCDIR}/${CERTNAME}" |  sed -n '/-----BEGIN/,/END CERTIFICATE-----/p' >> "${TARGETDIR}/${CERTNAME}"
      # echo -e '\n' >> "${TARGETDIR}/${CERTNAME}"
       echo "moved ${SRCDIR}/${CERTNAME}"
       let mcount=mcount+1
   elif [ -n ${matchNums} ]; then
       echo "file exists: ${matchNums}"
   fi

   palm=$(echo ${subtext} |  sed -rn 's/.*WebOS.*/&/p')
   if [ ${#palm} -gt 0 ]; then
        palmCerts="${palm};${palmCerts}"
        let pc=pc+1
   fi
   let count=count+1
done
echo "number of certs moved: ${mcount}"
echo "number of palm certs: ${pc}"
echo ${palmCerts}
./cleancerts.sh ./precerts
# Finally, generate the bundle and clean up.
#tar -zcvf root-certs.tar.gz certs
#we don't want a bundle cat certs/*.pem >  ${BUNDLE}
#  find -type l -print0 | tar -czvf calinks.tgz --null -T -
rm -r "${TEMPDIR}"
rm -f "${BUNDLE}"
find precerts/ -type f -name "*.pem"  -exec cat {} \; -exec echo "" \; > "${BUNDLE}"
cp ${BUNDLE} precerts/"${certdata}"
tar -czvf precerts/"${BUNDLE}.gz" "${BUNDLE}"