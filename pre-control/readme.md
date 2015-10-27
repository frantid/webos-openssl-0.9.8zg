control and source patch files for building for palm pre

postinst script backs up the default openssl files and installs the new files, plus updates the root cert bundle

cryptlib.h.patch - sets the default bundle file to ./certs/ca-certificates.crt

s_client.c.patch and s_time.c.patch - causes the default file and cert locations to be loaded if no CAfile
or CApath is set during an openssl s_client or s_time command.

ssl_lib.c.patch causes the default file and cert locations to be loaded for the ssl shared library  Credit for this patch belongs to https://github.com/tgaillar/OpenSSL-Updater
