#!/bin/sh

set -e

package=$1

echo "Deploying $package"

# go into the package directory
cd node_modules/$package

# delete build (force rebuild)
rm -rf build

# run migration
truffle migrate --network ${ETHEREUM_NETWORK:-development}

# go back
cd ../../..
