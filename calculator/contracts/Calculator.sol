pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract Calculator {

    DescartesInterface descartes;

    bytes32 templateHash = 0x88040f919276854d14efb58967e5c0cb2fa637ae58539a1c71c7b98b4f959baa;
    uint64 outputPosition = 0xa000000000000000;
    uint64 outputLog2Size = 10;
    uint256 finalTime = 1e13;
    uint256 roundDuration = 45;

    // mathematical expression to evaluate
    bytes expression = "2^71 + 36^12";
    uint64 expressionLog2Size = 5;

    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        // specifies an input drive containing the mathematical expression
        DescartesInterface.Drive[] memory drives = new DescartesInterface.Drive[](1);
        drives[0] = DescartesInterface.Drive(
            0x9000000000000000,    // 2nd drive position: 1st is the root file-system (0x8000..)
            expressionLog2Size,    // driveLog2Size
            expression,            // directValue
            0x00,                  // loggerRootHash
            claimer,               // provider
            false,                 // waitsProvider
            false                  // needsLogger
        );

        // instantiates the computation
        return descartes.instantiate(
            finalTime,
            templateHash,
            outputPosition,
            outputLog2Size,
            roundDuration,
            claimer,
            challenger,
            drives
        );
    }

    function getResult(uint256 index) public view returns (bool, bool, address, bytes memory) {
        return descartes.getResult(index);
    }

    function destruct(uint256 index) public {
        descartes.destruct(index);
    }
}
