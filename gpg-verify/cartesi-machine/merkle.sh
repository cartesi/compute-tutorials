#!/bin/bash

CARTESI_PLAYGROUND_DOCKER=cartesi/playground:0.5.0

if [ ! $2 ]; then
  echo "2 parameters required: file and tree size"
  exit 1
fi

merkle=$(docker run --rm \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --entrypoint "/opt/cartesi/bin/merkle-tree-hash" \
  $CARTESI_PLAYGROUND_DOCKER \
  --input=$1 --page-log2-size=$2 --tree-log2-size=$2)

echo $merkle
printf $merkle > $1.merkle
