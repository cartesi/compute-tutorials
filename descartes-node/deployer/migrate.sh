#!/bin/sh

echo "Unlocking account if geth is used"
truffle exec /opt/cartesi/deployer/unlockAccount.js --network ${ETHEREUM_NETWORK}

echo "Deploying @cartesi/util"
cd node_modules/@cartesi/util && truffle migrate --network ${ETHEREUM_NETWORK} && cd ../../..

echo "Deploying @cartesi/arbitration"
cd node_modules/@cartesi/arbitration && truffle migrate --network ${ETHEREUM_NETWORK} && cd ../../..

echo "Deploying @cartesi/machine-solidity-step"
cd node_modules/@cartesi/machine-solidity-step && truffle migrate --network ${ETHEREUM_NETWORK} && cd ../../..

echo "Deploying @cartesi/logger"
cd node_modules/@cartesi/logger && truffle migrate --network ${ETHEREUM_NETWORK} && cd ../../..

echo "Deploying @cartesi/descartes-sdk"
cd node_modules/@cartesi/descartes-sdk && truffle migrate --network ${ETHEREUM_NETWORK} && cd ../../..

echo "Copying json files to /opt/cartesi/share/blockchain"
rsync -aurRP --files-from=files . /opt/cartesi/share/blockchain

# XXX: fix this later, descartes configuration
mkdir -p /opt/cartesi/share/blockchain/build/contracts/
cp node_modules/@cartesi/descartes-sdk/build/contracts/Descartes.json /opt/cartesi/share/blockchain/build/contracts/
