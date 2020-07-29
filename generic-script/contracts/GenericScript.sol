pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract GenericScript {

    DescartesInterface descartes;

    uint256 finalTime = 1e13;
    bytes32 templateHash = 0x86374a11e83ac937078f753332e90966fb358fbf229040d2b17a08a476a6a54d;
    uint64 outputPosition = 0xa000000000000000;
    uint64 outputLog2Size = 10;
    uint256 roundDuration = 45;

    uint64 scriptLog2Size = 10;

    bytes script = "#!/usr/bin/lua\n\
        function fact (n)\n\
            if n <= 0 then\n\
                return 1\n\
            else\n\
                return n * fact(n-1)\n\
            end\n\
        end\n\
        print(fact(10))\n\
    ";


    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        // specifies an input drive containing the script
        DescartesInterface.Drive[] memory drives = new DescartesInterface.Drive[](1);
        drives[0] = DescartesInterface.Drive(
            0x9000000000000000,    // 2nd drive position: 1st is the root filesystem (0x80..0)
            scriptLog2Size,        // driveLog2Size
            script,                // directValue
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
