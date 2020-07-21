#!/bin/bash
cd libscrypt
export CC=riscv64-unknown-linux-gnu-gcc
export AR=riscv64-unknown-linux-gnu-ar
make clean
make
cd ..
