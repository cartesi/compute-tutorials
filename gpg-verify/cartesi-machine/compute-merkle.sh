#!/bin/bash

CARTESI_IPFS_DOCKER=cartesi/ipfs-server:0.2.0

if [ ! $3 ]; then
  echo "3 parameters required: file, blob size and tree size"
  exit 1
fi

docker run --rm \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --entrypoint "/opt/cartesi/bin/merkle-tree-hash" \
  $CARTESI_IPFS_DOCKER \
  --input=$1 --page-log2-size=$2 --tree-log2-size=$3
