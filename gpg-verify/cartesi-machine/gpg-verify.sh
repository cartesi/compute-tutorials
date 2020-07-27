#!/bin/sh

# reads document data as a binary string whose length is encoded in the first 2 bytes, and stores it in file 'doc'
dd status=none if=$(flashdrive doc) | lua -e 'io.write((string.unpack(">s2",  io.read("a"))))' > doc

# reads signature data as a binary string whose length is encoded in the first 2 bytes, and stores it in file 'signature'
dd status=none if=$(flashdrive signature) | lua -e 'io.write((string.unpack(">s2",  io.read("a"))))' > signature

# verifies doc signature
gpg --no-default-keyring --keyring /mnt/dapp-data/descartes-pub.key --verify signature doc

# writes gpg verification exit status to output (0 is success, 1 is error)
echo $? > $(flashdrive output)
