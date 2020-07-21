#!/bin/bash
riscv64-unknown-linux-gnu-gcc -O2 -o scrypt-hash scrypt-hash.c -Wl,-rpath=.  -Llibscrypt -lscrypt
cp scrypt-hash ext2
cp libscrypt/libscrypt.so.0 ext2
genext2fs -b 1024 -d ext2 scrypt-hash.ext2
