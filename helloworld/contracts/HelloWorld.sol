pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract HelloWorld {

    string defaultValue = "Hello World!";

    DescartesInterface descartes;

    uint256 finalTime = 1e13;
    bytes32 templateHash = 0x375fb938dcff562818779bc0dc4689a713a61d89659c8a9274a53551c7bc464c;
    uint64 outputPosition = 0x2700;
    uint256 roundDuration = 45;

    // output drive
    DescartesInterface.Drive[] drives;

    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        drives.push(DescartesInterface.Drive(
            0x00,    // position
            0x110,   // loggerLog2Size
            0,       // directValueOrLoggerRoot
            claimer, // TODO: claimer
            false,   // needsProvider
            false    // needsLogger
        ));

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

    function getResult(uint256 index) public view returns(string memory) {
        // TODO: use Descartes.getResult(index)
        return defaultValue;
    }
}
