const contract = require("@truffle/contract");
const HelloWorld = artifacts.require("HelloWorld");
const Descartes = contract(require("../../descartes-env/blockchain/node_modules/@cartesi/descartes-sdk/build/contracts/Descartes.json"));

module.exports = function(deployer) {
  Descartes.setNetwork(deployer.network_id);
  deployer.deploy(HelloWorld, Descartes.address);
};
