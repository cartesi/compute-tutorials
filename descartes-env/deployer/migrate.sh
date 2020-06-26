#!/bin/sh

set -e

abi_path=${ABI_PATH:-../blockchain}

echo "Unlocking account if geth is used"
truffle exec unlockAccount.js --network ${ETHEREUM_NETWORK:-development}

packages='@cartesi/util @cartesi/arbitration @cartesi/machine-solidity-step @cartesi/logger @cartesi/descartes-sdk'

# deploy each package, in the correct order
for package in $packages ; do
    ./migrate_package.sh $package
done

# copy json files we need for descartes
echo "Copying json files to $abi_path"
rsync -aurRP --files-from=files . $abi_path

# XXX: fix this later, descartes configuration
mkdir -p $abi_path/build/contracts/
cp node_modules/@cartesi/descartes-sdk/build/contracts/Descartes.json $abi_path/build/contracts/
