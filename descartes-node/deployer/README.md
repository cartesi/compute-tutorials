# Deployer

This node project is responsible for deploying [Descartes](https://github.com/cartesi/descartes) smart contract and all its dependent smart contracts to a local private test network, like the one created by [ganache-cli](https://github.com/trufflesuite/ganache-cli).

Descartes and all its dependencies are fetched using `yarn`, and stored at `./node_modules`, as any node project. You should have the following directories after running `yarn`:

```
./node_modules/@cartesi/arbitration
./node_modules/@cartesi/descartes-sdk
./node_modules/@cartesi/logger
./node_modules/@cartesi/machine-solidity-step
./node_modules/@cartesi/util
```

After all dependencies are at `./node_modules/@cartesi` the script `migrate.sh` can be used to deploy all contracts, in the correct order.

The `migrate.sh` script expects an environment variable called `ETHEREUM_NETWORK` to contain one of the networks defined at `truffle-config.js`, which are:

```javascript
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "7777", // test network
    },
    ganache: {
      host: "ganache",
      port: 8545,
      network_id: "7777", // test network
    },
  },
```

The `development` network is intended to be used when you have ganache (or any other ethereum node) running at `127.0.0.1:8545`.

The `ganache` network is intended to be used when you run the deployment inside a docker-compose environment that includes a ganache container (and hostname) running inside it.

Both networks expect a `network_id` 7777, which is fixed to facilitate the interoperability between this deployment phase and the execution phase of the tutorials.
