#!/bin/bash

CARTESI_LOGGER_DOCKER=cartesicorp/logger-server:latest
# CARTESI_LOGGER_DOCKER=cartesi/logger-server:0.6.2

if [ ! $3 ]; then
  echo "3 parameters required: file to submit, blob size and tree size"
  exit 1
fi

docker run --rm \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`/../..:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --network host \
  --entrypoint "/opt/cartesi/bin/simple-logger" \
  $CARTESI_LOGGER_DOCKER \
  -c descartes-env/deployments/localhost/Logger.json -d . --action submit -p "gpg-verify/cartesi-machine/$1" -b $2 -t $3

cat "$1.submit" && echo
