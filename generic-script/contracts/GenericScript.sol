pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract GenericScript {

    DescartesInterface descartes;

    uint256 finalTime = 1e13;
    bytes32 templateHash = 0x86374a11e83ac937078f753332e90966fb358fbf229040d2b17a08a476a6a54d;
    uint64 outputPosition = 0xa000000000000000;
    uint256 roundDuration = 45;
    DescartesInterface.Drive[] drives;

    uint64 scriptLog2Size;

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

        // expands script to 1024 bytes and defines scriptLog2Size accordingly
        script.length = 1024;
        scriptLog2Size = 10;
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        drives.push(DescartesInterface.Drive(
            0x9000000000000000,    // position
            scriptLog2Size,        // driveLog2Size
            script,                // directValue
            0x00,                  // loggerRootHash
            claimer,               // provider
            false,                 // waitsProvider
            false                  // needsLogger
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

    function getResult(uint256 index) public view returns (bool, bool, address, bytes32) {
        return descartes.getResult(index);
    }
}
