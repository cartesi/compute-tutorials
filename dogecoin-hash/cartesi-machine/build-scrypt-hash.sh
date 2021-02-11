#!/bin/bash
CARTESI_PLAYGROUND_DOCKER=cartesi/playground:0.3.0

# uses playground to build and package the scrypt-hash application for the Cartesi Machine
# - compiles "scrypt-hash" application, linking it to "libscrypt" (which should have been previously built)
# - builds an ext2 file-system file containing the application and the shared library
docker run \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER /bin/bash -c '\
    riscv64-cartesi-linux-gnu-gcc -O2 -o scrypt-hash scrypt-hash.c -Wl,-rpath=.  -Llibscrypt -lscrypt ;\
    mkdir -p ext2 ;\
    cp scrypt-hash ext2 ;\
    cp libscrypt/libscrypt.so.0 ext2 ;\
    genext2fs -b 1024 -d ext2 scrypt-hash.ext2 ;\
  '
