#!/bin/bash

CARTESI_LOGGER_DOCKER=cartesi/logger-server:0.7.0

if [ ! $3 ]; then
  echo "3 parameters required: file to submit, blob log2 size and tree log2 size"
  exit 1
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
BASEPATH=$SCRIPTPATH/../..
DOCPATH=$(realpath --relative-to=$BASEPATH $1)

docker run --rm \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v $BASEPATH:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --network host \
  --entrypoint "/opt/cartesi/bin/simple-logger" \
  $CARTESI_LOGGER_DOCKER \
  -c descartes-env/deployments/localhost/Logger.json -d . --action submit -p $DOCPATH -b $2 -t $3

cp $1.submit $1.merkle
cat $1.merkle && echo
