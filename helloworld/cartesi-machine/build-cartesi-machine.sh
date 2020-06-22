# general definitions
MACHINE_STORE_TEMP_DIR=__temp_machine_store
CARTESI_PLAYGROUND_DOCKER=cartesicorp/playground

# removes machine temp store directory if it exists
if [ -d "$MACHINE_STORE_TEMP_DIR" ]; then
  rm -r $MACHINE_STORE_TEMP_DIR
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
  -h playground \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER cartesi-machine \
    --append-rom-bootargs="quiet" \
    --flash-drive="label:output,length:1<<12" \
    --max-mcycle=0 \
    --initial-hash \
    --store="$MACHINE_STORE_TEMP_DIR" \
    -- $'echo Hello World! | dd status=none of=$(flashdrive output)'

# moves stored machine to a folder named after the machine's hash
mv $MACHINE_STORE_TEMP_DIR $(docker run \
  -e USER=$(id -u -n) \
  -e GROUP=$(id -g -n) \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -v `pwd`:/home/$(id -u -n) \
  -h playground \
  -w /home/$(id -u -n) \
  --rm $CARTESI_PLAYGROUND_DOCKER cartesi-machine-stored-hash $MACHINE_STORE_TEMP_DIR/)
