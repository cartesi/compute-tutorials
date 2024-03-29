#!/bin/bash
CARTESI_PLAYGROUND_DOCKER=cartesi/playground:0.5.0

# uses playground to build an ext2 file-system file containing the public key and the verification script
docker run \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER /bin/bash -c '\
    mkdir -p ext2 &&
    cp gpg-verify.sh ext2 &&
    cp compute-pub.key ext2 &&
    genext2fs -b 1024 -d ext2 dapp-data.ext2 \
  '
