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
        artifacts: "node_modules/@cartesi/compute-sdk/export/artifacts",
        deploy: "node_modules/@cartesi/compute-sdk/dist/deploy",
      },
    ],
    deployments: {
      localhost: ["../compute-env/deployments/localhost"],
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
task("instantiate", "Instantiate a DogecoinHash computation").setAction(
  async ({}, hre) => {
    const { ethers } = hre;
    const cartesiCompute = await ethers.getContract("CartesiCompute");
    const contract = await ethers.getContract("DogecoinHash");

    const { alice, bob } = await hre.getNamedAccounts();

    const tx = await contract.instantiate([alice, bob]);

    // retrieves created computation's index
    const index = await new Promise((resolve) => {
      cartesiCompute.on("CartesiComputeCreated", (index) => resolve(index));
    });

    console.log(
      `Instantiation successful with index '${index}' (tx: ${tx.hash} ; blocknumber: ${tx.blockNumber})\n`
    );
  }
);

// get-result task
task(
  "get-result",
  "Retrieves a DogecoinHash computation result given its index"
)
  .addOptionalParam("index", "The DogecoinHash computation index", 0, types.int)
  .setAction(async ({ index }, hre) => {
    const { ethers } = hre;
    const contract = await ethers.getContract("DogecoinHash");

    console.log("");
    console.log("Getting result using index '" + index + "'\n");

    const ret = await contract.getResult(index);
    console.log("Full result: " + JSON.stringify(ret));
    console.log("");
  });

// destruct task
task("destruct", "Destructs a DogecoinHash computation")
  .addOptionalParam("index", "The DogecoinHash computation index", 0, types.int)
  .setAction(async ({ index }, hre) => {
    const { ethers } = hre;
    const contract = await ethers.getContract("DogecoinHash");

    const tx = await contract.destruct(index);
    console.log(
      `Destruction successful for index '${index}' (tx: ${tx.hash} ; blocknumber: ${tx.blockNumber})\n`
    );
  });

export default config;
