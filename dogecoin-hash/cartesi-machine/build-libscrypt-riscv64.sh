#!/bin/bash
CARTESI_PLAYGROUND_DOCKER=cartesi/playground:0.5.0

# uses playground to build libscrypt for Cartesi Machine's RISC-V
# - sets "CC" as "riscv64-cartesi-linux-gnu-gcc"
# - sets "CFLAGS_EXTRA" as it is in libscrypt's Makefile, but removing flag "-fstack-protector", which is not supported
# - sets "PATH" to include the home directory (working directory), so as to call "riscv64-cartesi-linux-gnu-ar" when "ar" is invoked by the Makefile
# - calls "make clean" and "make" to build libscrypt
docker run \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER /bin/bash -c '\
    cd libscrypt ;\
    export CC=riscv64-cartesi-linux-gnu-gcc ;\
    export CFLAGS_EXTRA="-Wl,-rpath=. -O2 -Wall -g" ;\
    export PATH=$PATH:~/ ;\
    make clean ;\
    make ;\
  '
