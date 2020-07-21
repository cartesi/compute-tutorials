const contract = require("@truffle/contract");
const Descartes = contract(require("../../descartes-env/blockchain/node_modules/@cartesi/descartes-sdk/build/contracts/Descartes.json"));

const DogecoinHash = artifacts.require("DogecoinHash");

module.exports = function(deployer) {
  Descartes.setNetwork(deployer.network_id);
  deployer.deploy(DogecoinHash, Descartes.address);
};
