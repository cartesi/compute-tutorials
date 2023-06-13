// Copyright (C) 2021 Cartesi Pte. Ltd.

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

/// @title HelloWorld
/// @author Milton Jonathan
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/compute-sdk/contracts/CartesiComputeInterface.sol";

contract HelloWorld {

    CartesiComputeInterface cartesiCompute;

    bytes32 templateHash = 0x3e4891f40155c257c143ee164aac14f07c30405dc13ab8f253cbaaf348c54ac9;
    uint64 outputPosition = 0x90000000000000;
    uint8 outputLog2Size = 5;
    uint256 finalTime = 1e11;
    uint256 roundDuration = 51;
    CartesiComputeInterface.Drive[] drives;

    constructor(address cartesiComputeAddress) {
        cartesiCompute = CartesiComputeInterface(cartesiComputeAddress);
    }

    function instantiate(address[] memory parties) public returns (uint256) {

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

