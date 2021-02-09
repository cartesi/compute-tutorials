# Descartes SDK Tutorials

This project contains tutorial DApps implemented with the Descartes SDK, as documented in https://cartesi.io/docs/

## Getting Started

### Requirements

- docker
- docker-compose
- node 12.x
- yarn

### Cloning

```
$ git clone git@github.com:cartesi/descartes-tutorials.git
```
or using the http address:
```
$ git clone https://github.com/cartesi/descartes-tutorials.git
```

### Environment

All tutorials in this repository are designed to interact with [Descartes](https://github.com/cartesi/descartes) nodes running locally.
Both the tutorials and the Descartes nodes are configured to interact with a local Hardhat Ethereum node running at `localhost:8545`. The environment is configured for two actors, `alice` and `bob`, each of which has an account in the Ethereum instance as well as a corresponding Descartes node.

To run the entire environment, execute:
```bash
$ cd descartes-env
$ docker-compose up
```

ATTENTION: to shutdown the environment, remember to remove volumes when stopping the containers:
```bash
$ docker-compose down -v
```


## Running a DApp tutorial

Each subdirectory contains an independent DApp tutorial. Each tutorial consists of:
- A smart contract, along with any dependencies and deploy scripts
- The specification of a Cartesi Machine that performs a computation

To run each tutorial, first `cd` into its directory. For instance:
```bash
$ cd helloworld
```

Then build the DApp's Cartesi Machine and store it in an appropriate directory accessible by the Descartes nodes. To do this, execute the following:
```bash
$ cd cartesi-machine
$ ./build-cartesi-machine.sh ../../descartes-env/machines
```
> **Note:** for some tutorials, building an appropriate machine requires a custom `rootfs.ext2` file-system drive. This process is [documented here](https://docs.cartesi.io/machine/target/linux#the-root-file-system). More specific instructions are given within each tutorial.

Install, compile and deploy the DApp's smart contract to the local `hardhat` node (which is the same instance used by the Descartes services):
```bash
$ yarn
$ npx hardhat deploy --network localhost
```

Once this is done, the DApp can be tested using the `hardhat` console. For instance, for the HelloWorld DApp one can use:
```bash
$ npx hardhat console --network localhost
> { alice, bob } = await getNamedAccounts()
> hw = await ethers.getContract("HelloWorld")
> hw.instantiate([alice, bob])
```

After the computation completes, it will be possible to query the results:
```bash
> res = await hw.getResult(0)
[
  true,
  false,
  '0x0000000000000000000000000000000000000000',
  '0x48656c6c6f20576f726c64210a00000000000000000000000000000000000000'
]
> ethers.utils.toUtf8String(res[3])
'Hello World!\n\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
```

Aside from the `hardhat` console, you can also run the DApps using pre-defined tasks configured in each project's `hardhat.config.ts` file. For instance, you can use the `instantiate` task for the HelloWorld DApp as follows:

```bash
$ npx hardhat --network localhost instantiate
Instantiation successful with index '1' (tx: 0xa683a858f4ffb3716d26b00945be96e5f1519a0d0639cfc96c42ebd5bbbb3a96 ; blocknumber: 42)
```

And then, after some time you can retrieve the corresponding results by running the `get-result` task specifying the appropriate index:
```bash
$ npx hardhat --network localhost get-result --index 1

Getting result using index '1'

Full result: [true,false,"0x0000000000000000000000000000000000000000","0x48656c6c6f20576f726c64210a00000000000000000000000000000000000000"]
Result value as string: Hello World!
```

Each DApp project may define specific parameters in their corresponding task configurations within `hardhat.config.ts`.

## Creating a new DApp

First of all, create a subdirectory for the DApp and `cd` into it:
```bash
$ mkdir mydapp
$ cd mydapp
```

Add project dependencies. Besides Descartes itself, we recommend deploying the smart contracts using Hardhat and Ethers, as well as using Typescript in configuration files and scripts:
```bash
$ yarn add @cartesi/descartes-sdk
$ yarn add ethers hardhat hardhat-deploy hardhat-deploy-ethers --dev
$ yarn add typescript ts-node --dev
```

Create a `hardhat.config.ts` file that specifies the dependency on `@cartesi/descartes-sdk` artifacts and deployment scripts, as well as the usage of the Descartes Environment's Ethereum instance running on `localhost:8545`. It is also recommended to define a `deployer` named account to use when deploying the contracts:
```javascript
import { HardhatUserConfig } from "hardhat/config";

import "hardhat-deploy";
import "hardhat-deploy-ethers";

const config: HardhatUserConfig = {
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
  },
  solidity: {
    version: "0.7.4",
  },
  external: {
    contracts: [
      {
        artifacts: "node_modules/@cartesi/descartes-sdk/export/artifacts",
        deploy: "node_modules/@cartesi/descartes-sdk/dist/deploy",
      },
    ],
    deployments: {
      localhost: ["../descartes-env/deployments/localhost"],
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
```

Create the smart contract for the DApp in `./contracts` (e.g., `./contracts/MyDapp.sol`). It should import `DescartesInterface` to be able to use the Descartes contract:
```javascript
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";

contract MyDapp {
    DescartesInterface descartes;

    constructor(address descartesAddress) {
        descartes = DescartesInterface(descartesAddress);
    }
}
```

Create a deploy script `./deploy/01_contracts.ts` to publish the DApp smart contract linked to the deployed Descartes smart contract:
```javascript
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const Descartes = await get("Descartes");
  await deploy("MyDapp", {
    from: deployer,
    log: true,
    args: [Descartes.address],
  });
};

export default func;
```

Run `hardhat deploy` to publish the contract to the local network:
```bash
$ npx hardhat deploy --network localhost
```


## Using a local Descartes build (optional)

In order to run these tutorials with a local build of the [Descartes project](https://github.com/cartesi/descartes), first of all clone that repository, making sure to include the submodules. For instance:

```bash
$ cd ..
$ git clone --recurse-submodules git@github.com:cartesi/descartes.git
```

Then, build the Descartes Docker image (this will take some time):

```bash
$ cd descartes
$ docker build . -t cartesi/descartes:local
```

After that, use Yarn to pack Descartes' dependencies as a gzip compressed file, and place that file inside the `descartes-env` directory within `descartes-tutorials`. For instance:

```bash
$ yarn pack --filename ../descartes-tutorials/descartes-env/cartesi-descartes-sdk-local.tgz
```

Back in the `descartes-tutorials` project, change the Docker Compose configuration used by your local Environment by editing `descartes-env/docker-compose.yml`, so that `alice`'s and `bob`'s dispatchers use the newly built Docker image:

```yml
  ...
  alice_dispatcher:
    image: cartesi/descartes:local
  ...
  bob_dispatcher:
    image: cartesi/descartes:local
  ...
```

Then, `cd` into the `descartes-env` directory and use Yarn to make sure the local Descartes Environment uses the generated gzip file with Descartes' dependencies:

```bash
$ cd ./descartes-env
$ yarn add file:./cartesi-descartes-sdk-local.tgz
```

At this point, you can clean up your Descartes Environment and redeploy it with the updated setup:

```bash
$ docker-compose down -v
$ docker-compose up
```

Finally, `cd` into the tutorial project of interest, and also ensure it uses the same generated gzip file with Descartes' dependencies:

```bash
$ cd ../<tutorial-project>
$ yarn add file:../descartes-env/cartesi-descartes-sdk-local.tgz
```

## Contributing

Thank you for your interest in Cartesi! Head over to our [Contributing Guidelines](CONTRIBUTING.md) for instructions on how to sign our Contributors Agreement and get started with Cartesi!

Please note we have a [Code of Conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

