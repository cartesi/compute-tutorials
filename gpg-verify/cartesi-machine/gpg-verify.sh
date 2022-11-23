#!/bin/sh

# reads document data as a binary string whose length is encoded in the first 4 bytes, and stores it in file 'document'
dd status=none if=$(flashdrive document) | lua -e 'io.write((string.unpack(">s4",  io.read("a"))))' > document

# reads signature data as a binary string whose length is encoded in the first 4 bytes, and stores it in file 'signature'
dd status=none if=$(flashdrive signature) | lua -e 'io.write((string.unpack(">s4",  io.read("a"))))' > signature

# imports public key informing that it can be trusted (0xA86D9CB964EB527E is the key's LONG id)
gpg --trusted-key 0xA86D9CB964EB527E --import /mnt/dapp-data/compute-pub.key

# verifies document signature
gpg --verify signature document

# writes gpg verify's exit status to output: 0 is success, 1 is failure, other values indicate error
echo $? > $(flashdrive output)
