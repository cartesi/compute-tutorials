import { HardhatUserConfig, task, types } from "hardhat/config";

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
    alice: {
      default: 0,
    },
    bob: {
      default: 1,
    },
  },
};

// TASKS

// instantiate task
task("instantiate", "Instantiate a GenericScript computation").setAction(
  async ({}, hre) => {
    const { ethers } = hre;
    const descartes = await ethers.getContract("Descartes");
    const contract = await ethers.getContract("GenericScript");

    const { alice, bob } = await hre.getNamedAccounts();

    const tx = await contract.instantiate([alice, bob]);

    // retrieves created computation's index
    const index = await new Promise((resolve) => {
      descartes.on("DescartesCreated", (index) => resolve(index));
    });

    console.log(
      `Instantiation successful with index '${index}' (tx: ${tx.hash} ; blocknumber: ${tx.blockNumber})\n`
    );
  }
);

// get-result task
task(
  "get-result",
  "Retrieves a GenericScript computation result given its index"
)
  .addOptionalParam(
    "index",
    "The GenericScript computation index",
    0,
    types.int
  )
  .setAction(async ({ index }, hre) => {
    const { ethers } = hre;
    const contract = await ethers.getContract("GenericScript");

    console.log("");
    console.log("Getting result using index '" + index + "'\n");

    const ret = await contract.getResult(index);
    console.log("Full result: " + JSON.stringify(ret));
    if (ret["3"]) {
      console.log(
        `Result value as string: ${ethers.utils.toUtf8String(ret["3"])}`
      );
    }
    console.log("");
  });

// destruct task
task("destruct", "Destructs a GenericScript computation")
  .addOptionalParam(
    "index",
    "The GenericScript computation index",
    0,
    types.int
  )
  .setAction(async ({ index }, hre) => {
    const { ethers } = hre;
    const contract = await ethers.getContract("GenericScript");

    const tx = await contract.destruct(index);
    console.log(
      `Destruction successful for index '${index}' (tx: ${tx.hash} ; blocknumber: ${tx.blockNumber})\n`
    );
  });

export default config;
