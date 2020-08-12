pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract DogecoinHash {

    DescartesInterface descartes;

    bytes32 templateHash = 0x8bc459031809fcb366953f8373b3f202450ecbae51f3f724354480638725ff38;

    // this DApp has an ext2 file-system (at 0x9000..) and an input drives (at 0xa000), so the output will be at 0xb000..
    uint64 outputPosition = 0xb000000000000000;
    // output hash has 32 bytes
    uint64 outputLog2Size = 5;

    uint256 finalTime = 1e13;
    uint256 roundDuration = 45;

    // header data for DOGE block #100000 (https://dogechain.info/block/100000)
    bytes4 version = 0x20000000;
    bytes32 prevBlock = 0xb417303fb9ac36d8323050124d7298827e1da58cd1f66cb8d0aea8caf37d9095;
    bytes32 merkleRootHash = 0x3e17b9b078117ea1f51bd0f8ac9a346cb99ee0bc97c97fa93d7d789311f442e9;
    bytes4 timestamp = 0x5f189264;         // 2020-07-22 19:24:20, which is timestamp 1595445860 in decimal
    bytes4 difficultyBits = 0x1a01cd2d;
    bytes4 nonce = 0x84dd91a8;

    // input data for the scrypt hashing algorithm, based on the header info
    // - actual size is 80 bytes, next power of 2 size is 128
    bytes headerData = new bytes(128);
    uint64 headerDataLog2Size = 7;


    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);

        // defines headerData by concatenating block header fields
        uint iHeader = 0;
        uint i;
        for (i = 0; i < version.length; i++)        {headerData[iHeader++] = version[i];}
        for (i = 0; i < prevBlock.length; i++)      {headerData[iHeader++] = prevBlock[i];}
        for (i = 0; i < merkleRootHash.length; i++) {headerData[iHeader++] = merkleRootHash[i];}
        for (i = 0; i < timestamp.length; i++)      {headerData[iHeader++] = timestamp[i];}
        for (i = 0; i < difficultyBits.length; i++) {headerData[iHeader++] = difficultyBits[i];}
        for (i = 0; i < nonce.length; i++)          {headerData[iHeader++] = nonce[i];}
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        // specifies an input drive with the header data to be hashed using scrypt
        DescartesInterface.Drive[] memory drives = new DescartesInterface.Drive[](1);
        drives[0] = DescartesInterface.Drive(
            0xa000000000000000,    // 3rd drive position: 1st is the root file-system (0x8000..), 2nd is the mounted ext2 filesystem (0x9000..)
            headerDataLog2Size,    // driveLog2Size
            headerData,            // directValue
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
