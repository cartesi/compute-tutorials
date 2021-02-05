import { HardhatUserConfig } from "hardhat/config";

import "@nomiclabs/hardhat-ethers";
import "hardhat-deploy";

// read MNEMONIC from file or from env variable
let mnemonic = process.env.MNEMONIC;

const config: HardhatUserConfig = {
  networks: {
    localhost: {
      url: "http://localhost:8545",
      accounts: mnemonic ? { mnemonic } : undefined,
    },
  },
  solidity: {
    version: "0.7.4",
    settings: {
      optimizer: {
        runs: 110,
        enabled: true,
      },
    },
  },
  paths: {
    artifacts: "artifacts",
    deploy: "deploy",
    deployments: "deployments",
  },
  external: {
    contracts: [
      {
        artifacts: "node_modules/@cartesi/util/export/artifacts",
        deploy: "node_modules/@cartesi/util/dist/deploy",
      },
      {
        artifacts: "node_modules/@cartesi/arbitration/export/artifacts",
        deploy: "node_modules/@cartesi/arbitration/dist/deploy",
      },
      {
        artifacts: "node_modules/@cartesi/logger/export/artifacts",
        deploy: "node_modules/@cartesi/logger/dist/deploy",
      },
      {
        deploy: "node_modules/@cartesi/machine-solidity-step/dist/deploy",
        artifacts:
          "node_modules/@cartesi/machine-solidity-step/export/artifacts",
      },
      {
        deploy: "node_modules/@cartesi/descartes-sdk/dist/deploy",
        artifacts: "node_modules/@cartesi/descartes-sdk/export/artifacts",
      },
    ],
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    proxy: {
      default: 1,
    },
    alice: {
      default: 0,
    },
    bob: {
      default: 1,
    },
  },
};

export default config;
