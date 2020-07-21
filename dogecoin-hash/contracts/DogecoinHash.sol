pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract DogecoinHash {

    DescartesInterface descartes;

    uint256 finalTime = 1e13;
    bytes32 templateHash = 0x063f3bca7762aa7107c7c0dbdbe9dc4c4cd66ff4a32aabc889278b993e342cf8;
    uint64 outputPosition = 0xb000000000000000;
    uint256 roundDuration = 45;

    
    // data for DOGE block #100000 (https://dogechain.info/block/100000)
    bytes4 version = 0x00000002;
    bytes32 prevBlock = 0x12aca0938fe1fb786c9e0e4375900e8333123de75e240abd3337d1b411d14ebe;
    bytes32 merkleRootHash = 0x31757c266102d1bee62ef2ff8438663107d64bdd5d9d9173421ec25fb2a814de;
    bytes4 timestamp = 0x52fd869d;         // 2014-02-13 18:59:41 -0800, which is timestamp 1392346781 in decimal
    bytes4 difficultyBits = 0x1b267eeb;
    bytes4 nonce = 0x84214800;             // 2216773632 in decimal

    // creates header bytes: actual size is 80, next power of 2 size is 128
    bytes headerData = new bytes(128);
    uint64 headerDataLog2Size = 7;


    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);

        // inserts info into headerData
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

        // specifies an input drive containing the script
        DescartesInterface.Drive[] memory drives = new DescartesInterface.Drive[](1);
        drives[0] = DescartesInterface.Drive(
            0xa000000000000000,    // 3rd drive position: 1st is the root filesystem (0x80..0), 2nd is the mounted ext2 filesystem (0x90..0)
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
