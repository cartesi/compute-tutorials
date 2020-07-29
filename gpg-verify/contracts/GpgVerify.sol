pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract GpgVerify {

    DescartesInterface descartes;

    // this DApp has an ext2 file-system (at 0x90..00) and two input drives (at 0xa0..00 and 0xb0..00), so the output will be at 0xc0..00
    uint64 outputPosition = 0xc000000000000000;
    // output will be "0" (success, no errors), "1" (failure), or some other error code that certainly fits into the minimum size of 32 bytes
    uint64 outputLog2Size = 5;

    bytes32 templateHash = 0x3216779ec9659f48e7ec0b96342e4ae4b4a2e2f98813b75a9a7668e74dcf082f;

    uint256 finalTime = 1e13;
    uint256 roundDuration = 45;

    // document that was signed
    bytes doc = "My public statement\n";

    // detached signature for the document, produced with a private key
    // - the DApp off-chain code must contain the corresponding public key in order to verify the signature
    bytes signature = hex'8901d20400010a003d162104dbbbb50ddc0910795f7c0b48a86d9cb964eb527e05025f19fa431f1c6465736361727465732e'
                      hex'7475746f7269616c7340636172746573692e696f000a0910a86d9cb964eb527ed88f0bf745cac22eca54a050edf5ce62ab5c'
                      hex'8857bab9807d4b6cc4b01b47c640669f14c9457d129225d005585f7a4cec2c41bd088b0d622c4ee29eecb4a451461e421d00'
                      hex'67575bd845818a12df0b197e525da3dea2c89f0210325d766a11da824d9469bea5add6c9f91c09098f72cca806f4b0eb3ff6'
                      hex'22531171f9ae5b855366d250d08e05327549a9a958b44530f2a05cd9b6aa463eda223f16ff8655ab2e4bf7f66bb2fa29913c'
                      hex'1f04080a24dd10e754d277c346909a3510305b7fd9ca2a4bbd412fc50818331b40461380174434f90046bfb6278419b69259'
                      hex'e56abfa504c5965e37d1aa355302d8b6aac98abe5be1c02c78d5a2e9e4df0eba43a91717407811e20b800120f349aa1b51a1'
                      hex'e4ad5ffdf6248ef0201b275e947d81ed8267a473778cab78ead5f39e60edaf9c17a6c558eeb0ca7e7acc1343a1f7a431d215'
                      hex'98edd470a080ed377ab0c4824f95589ab1c40568e8a28b36ac20116586f89ebe193af5898aa947ada15bbbb8d09e3894c33d'
                      hex'7bdb20a8b1bc6be60ac03fdbc0be0ffdfa326c';

    // corresponding document and signature data to be sent as input drives to the off-chain Cartesi Machine
    // - this machine expects the first two bytes of the input data to encode the length of the content of interest
    bytes docData = new bytes(1024);
    bytes signatureData = new bytes(1024);

    constructor(address descartesAddress) public {
        descartes = DescartesInterface(descartesAddress);

        // prepares data: computation expects input data to be prepended by two bytes that encode the length of the content
        prepareData(doc, docData);
        prepareData(signature, signatureData);
    }

    function prepareData(bytes storage input, bytes storage data) internal {
        // length is assumed to fit in two bytes
        assert(input.length <= 0xffff);

        // sets first two bytes in "data" as the input length
        bytes memory inputLength = abi.encodePacked(input.length);
        data[0] = inputLength[inputLength.length-2];
        data[1] = inputLength[inputLength.length-1];

        // subsequent bytes in "data" are the input bytes themselves
        for (uint i = 0; i < input.length && i+2 < data.length; i++) {
          data[i+2] = input[i];
        }
    }

    function instantiate(address claimer, address challenger) public returns (uint256) {

        // specifies two input drives containing the document and the signature
        DescartesInterface.Drive[] memory drives = new DescartesInterface.Drive[](2);
        drives[0] = DescartesInterface.Drive(
            0xa000000000000000,    // position
            10,                    // driveLog2Size
            docData,               // directValue
            0x00,                  // loggerRootHash
            claimer,               // provider
            false,                 // waitsProvider
            false                  // needsLogger
        );
        drives[1] = DescartesInterface.Drive(
            0xb000000000000000,    // position
            10,                    // driveLog2Size
            signatureData,         // directValue
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
