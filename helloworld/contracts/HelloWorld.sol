pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract HelloWorld {

    string defaultValue = "Hello World!";

    DescartesInterface descartes;

    uint256 finalTime = 1e13;
    bytes32 templateHash = 0x1697a8f2587ec67aafbfee38f8287c3ca5ce8b2822291ba9cfbfa6ffb37fdb53;
    uint64 outputPosition = 0x9000000000000000;
    uint256 roundDuration = 45;
    DescartesInterface.Drive[] drives;

    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        return descartes.instantiate(
            finalTime,
            templateHash,
            outputPosition,
            roundDuration,
            claimer,
            challenger,
            drives
        );
    }

    function getResult(uint256 index) public view returns (bool, bool, address, bytes32) {
        return descartes.getResult(index);
    }
}
