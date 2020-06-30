# Descartes SDK Tutorials

This project contains tutorial DApps implemented with the Descartes SDK, as documented in https://cartesi.io/docs/

## Getting Started

### Requirements

- docker
- docker-compose
- node 12.x
- yarn
- truffle

### Cloning

```
git clone ssh://github.com/cartesi/descartes-tutorials.git
```
or using the http address:
```
git clone https://github.com/cartesi/descartes-tutorials.git
```

### Environment

All tutorials in this repository are designed to interact with [Descartes](https://github.com/cartesi/descartes) nodes running locally.
Both the tutorials and the Descartes nodes are configured to interact with a local [ganache](https://github.com/trufflesuite/ganache-cli) instance running at `localhost:8545`. The environment is configured for two actors, `alice` and `bob`, each of which has an account in the `ganache` instance as well as a corresponding Descartes node.

To initialize the local `ganache` network and deploy the `Descartes` smart contract there, execute:
```bash
% cd descartes-env
% make deploy
```
(you should manually stop the ganache instance once deploy is complete)

To run the entire environment, execute:
```bash
% cd descartes-env
% docker-compose up
```

## Running a DApp tutorial

Each subdirectory contains an independent DApp tutorial. Each tutorial consists of:
- A smart contract, along with any dependencies and migrations
- The specification of a Cartesi Machine that performs a computation

To run each tutorial, first `cd` into its directory. For instance:
```bash
% cd helloworld
```

Then build the DApp's Cartesi Machine and store it in an appropriate directory accessible by the Descartes nodes. To do this, execute the following:
```bash
% ./cartesi-machine/build-cartesi-machine.sh ../descartes-env/machines
```

Install, compile and migrate the DApp's smart contract (project configuration is set to use the same local ganache instance used by the Descartes nodes):
```bash
% yarn
% truffle migrate
```

Once this is done, the DApp can be tested using `truffle console`. For instance, for the HelloWorld DApp one can use:
```bash
% truffle console
truffle(development)> web3.eth.getAccounts()
[
  '0xe9bE0C14D35c5fA61B8c0B34f4c4e2891eC12e7E',
  '0x91472CCE70B1080FdD969D41151F2763a4A22717'
]
truffle(development)> hw = await HelloWorld.deployed()
truffle(development)> hw.instantiate('0xe9bE0C14D35c5fA61B8c0B34f4c4e2891eC12e7E', '0x91472CCE70B1080FdD969D41151F2763a4A22717')
```

After the computation completes, it will be possible to query the results:
```bash
truffle(development)> res = await hw.getResult(0)
truffle(development)> res
Result {
    '0': true,
    '1': false,
    '2': '0x0000000000000000000000000000000000000000',
    '3': '0x48656c6c6f20576f726c64210a00000000000000000000000000000000000000'
}
truffle(development)> web3.utils.toAscii(res['3'])
'Hello World!\n\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
```

## Creating a new DApp

First of all, create a subdirectory for the DApp and initialize it with truffle:
```bash
% mkdir mydapp
% cd mydapp
% truffle init
```

The default network uses localhost on port 7545. To use the local `ganache` instance, we must edit `truffle-config.js` to specify port 8545:
```javascript
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
  },
```

Add project dependency to Descartes and to `@truffle/contract` (used for migrating the smart contracts):
```bash
% yarn add @cartesi/descartes-sdk
% yarn add @truffle/contract
```

Create the smart contract for the DApp in `./contracts` (e.g., `./contracts/MyDapp.sol`). It should import `DescartesInterface` to be able to use the Descartes contract:
```javascript
pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";

contract MyDapp {
    DescartesInterface descartes;

    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);
    }
}
```

Create a migration file `./migrations/2_deploy_contracts.js` to publish the DApp smart contract linked to the Descartes smart contract:
```javascript
const contract = require("@truffle/contract");
const Descartes = contract(require("../../descartes-env/blockchain/node_modules/@cartesi/descartes-sdk/build/contracts/Descartes.json"));
const MyDapp = artifacts.require("MyDapp");

module.exports = function(deployer) {
  Descartes.setNetwork(deployer.network_id);
  deployer.deploy(MyDapp, Descartes.address);
};
```

Run `truffle migrate` to publish contract to the network:
```bash
% truffle migrate
```


## Contributing

Thank you for your interest in Cartesi! Head over to our [Contributing Guidelines](CONTRIBUTING.md) for instructions on how to sign our Contributors Agreement and get started with Cartesi!

Please note we have a [Code of Conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

