// Copyright (C) 2020 Cartesi Pte. Ltd.

// SPDX-License-Identifier: GPL-3.0-only
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.

// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Note: This component currently has dependencies that are licensed under the GNU
// GPL, version 3, and so you should treat this component as a whole as being under
// the GPL version 3. But all Cartesi-written code in this component is licensed
// under the Apache License, version 2, or a compatible permissive license, and can
// be used independently under the Apache v2 license. After this component is
// rewritten, the entire component will be released under the Apache v2 license.

/// @title DogecoinHash
/// @author Milton Jonathan
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/compute-sdk/contracts/CartesiComputeInterface.sol";


contract DogecoinHash {

    CartesiComputeInterface cartesiCompute;

    bytes32 templateHash = 0xb48fa074594a537fcc7c1069fc3eeabcbbcabff6f479c08a5c12efdd73b4ca20;

    // this DApp has an ext2 file-system (at 0x9000..) and an input drives (at 0xa000), so the output will be at 0xb000..
    uint64 outputPosition = 0xb000000000000000;
    // output hash has 32 bytes
    uint8 outputLog2Size = 5;

    uint256 finalTime = 1e11;
    uint256 roundDuration = 51;

    // header data for DOGE block #100000 (https://dogechain.info/block/100000)
    bytes4 version = 0x00000002;
    bytes32 prevBlock = 0x12aca0938fe1fb786c9e0e4375900e8333123de75e240abd3337d1b411d14ebe;
    bytes32 merkleRootHash = 0x31757c266102d1bee62ef2ff8438663107d64bdd5d9d9173421ec25fb2a814de;
    bytes4 timestamp = 0x52fd869d;         // 2014-02-13 18:59:41 -0800, which is timestamp 1392346781 in decimal
    bytes4 difficultyBits = 0x1b267eeb;
    bytes4 nonce = 0x84214800;             // 2216773632 in decimal

    // input data for the scrypt hashing algorithm, based on the header info
    // - actual size is 80 bytes, next power of 2 size is 128
    bytes headerData = new bytes(128);
    uint8 headerDataLog2Size = 7;


    constructor(address cartesiComputeAddress) {
        cartesiCompute = CartesiComputeInterface(cartesiComputeAddress);

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

    function instantiate(address[] memory parties) public returns (uint256) {

        // specifies an input drive with the header data to be hashed using scrypt
        CartesiComputeInterface.Drive[] memory drives = new CartesiComputeInterface.Drive[](1);
        drives[0] = CartesiComputeInterface.Drive(
            0xa000000000000000,    // 3rd drive position: 1st is the root file-system (0x8000..), 2nd is the mounted ext2 filesystem (0x9000..)
            headerDataLog2Size,    // driveLog2Size
            headerData,            // directValue
            "",                    // loggerIpfsPath
            0x00,                  // loggerRootHash
            parties[0],            // provider
            false,                 // waitsProvider
            false,                  // needsLogger
            false                   // downloadAsCor
        );

        // instantiates the computation
        return cartesiCompute.instantiate(
            finalTime,
            templateHash,
            outputPosition,
            outputLog2Size,
            roundDuration,
            parties,
            drives,
            false
        );
    }

    function getResult(uint256 index) public view returns (bool, bool, address, bytes memory) {
        return cartesiCompute.getResult(index);
    }

    function destruct(uint256 index) public {
        cartesiCompute.destruct(index);
    }
}
