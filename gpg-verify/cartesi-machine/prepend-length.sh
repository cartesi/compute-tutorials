#!/bin/bash

CARTESI_PLAYGROUND_DOCKER=cartesi/playground:0.3.0

if [ ! $1 ]; then
  echo "1 parameter required: file"
  exit 1
fi

docker run --rm \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  $CARTESI_PLAYGROUND_DOCKER /bin/bash -c \
  "dd status=none if=$1 | luapp5.3 -e 'io.write((string.pack(\">s4\",  io.read(\"a\"))))' > $1.prepended"

echo Generated $1.prepended
