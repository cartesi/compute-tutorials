#!/bin/bash

# general definitions
MACHINES_DIR=.
MACHINE_TEMP_DIR=__temp_machine
CARTESI_PLAYGROUND_DOCKER=cartesi/playground:0.5.0

# set machines directory to specified path if provided
if [ $1 ]; then
  MACHINES_DIR=$1
fi

# removes machine temp store directory if it exists
if [ -d "$MACHINE_TEMP_DIR" ]; then
  rm -r $MACHINE_TEMP_DIR
fi

# builds machine (running with 0 cycles)
# - initial (template) hash is printed on screen
# - machine is stored in temporary directory
docker run \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER cartesi-machine \
    --max-mcycle=0 \
    --initial-hash \
    --append-rom-bootargs="single=yes" \
    --store="$MACHINE_TEMP_DIR" \
    --flash-drive="label:dapp-data,filename:dapp-data.ext2" \
    --flash-drive="label:document,length:1<<22" \
    --flash-drive="label:signature,length:1<<12" \
    --flash-drive="label:output,length:1<<12" \
    -- $'date -s \'2100-01-01\' && /mnt/dapp-data/gpg-verify.sh'

# defines target directory as being within $MACHINES_DIR and named after the stored machine's hash
MACHINE_TARGET_DIR=$MACHINES_DIR/$(docker run \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -h playground \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER cartesi-machine-stored-hash $MACHINE_TEMP_DIR/ | tail -n 1)

# moves stored machine to the target directory
if [ -d "$MACHINE_TARGET_DIR" ]; then
  rm -r $MACHINE_TARGET_DIR
fi
mv $MACHINE_TEMP_DIR $MACHINE_TARGET_DIR
