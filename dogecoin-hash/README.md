# Dogecoin/Litecoin Hash Tutorial

This tutorial DApp uses the [scrypt](https://www.tarsnap.com/scrypt.html) algorithm to compute the proof-of-work hash for Dogecoin or Litecoin block headers. The resulting hash can then be compared to the target difficulty of the block, in order to validate it.


## Background

Dogecoin is actually based on Litecoin, and both use the same algorithm for hashing blocks. The specification for Litecoin's block hashing algorithm can be found [here](https://litecoin.info/index.php/Block_hashing_algorithm).

The specification defines that the data to be hashed should be composed of the concatenation of 6 fields from the block header:

1. Version (4 bytes)
1. Previous hash (32 bytes)
1. Merkle root (32 bytes)
1. Timestamp (4 bytes)
1. Bits (target value in compact form) (4 bytes)
1. Nonce (4 bytes)

As such, the provided input data must be 80 bytes in size.

The specification also defines that the resulting hash must have a length of 32 bytes (256 bits), and should be smaller than the *target value* encoded in the `Bits` field. In other words, for a block to be valid the miner must have provided an adequate `Nonce` value such that the resulting hash is small enough. In order to compare the computed hash with the target value, it is necessary to interpret the 4 bytes of the `Bits` field as defined by the specification. In a nutshell, the leading byte is a base-256 exponent and the other 3 bytes are the mantissa. As an example, the target for a `Bits` value of `1a01cd2d` will be given by:
```
target = 01cd2d << 8*(1a - 3) = 1cd2d0000000000000000000000000000000000000000000000
```


## Usage

The [DogecoinHash.sol](./contracts/DogecoinHash.sol) file contains data corresponding to [DOGE block #100000](https://dogechain.info/block/100000).

```
bytes4 version = 0x00000002;
bytes32 prevBlock = 0x12aca0938fe1fb786c9e0e4375900e8333123de75e240abd3337d1b411d14ebe;
bytes32 merkleRootHash = 0x31757c266102d1bee62ef2ff8438663107d64bdd5d9d9173421ec25fb2a814de;
bytes4 timestamp = 0x52fd869d;         // 2014-02-13 18:59:41 -0800, which is timestamp 1392346781 in decimal
bytes4 difficultyBits = 0x1b267eeb;
bytes4 nonce = 0x84214800;             // 2216773632 in decimal
```

As described [above](#background), the hash returned by the computation can be used to verify if the block header is indeed valid. For this block, the target value encoded in the `difficultyBits` variable `0x1b267eeb` corresponds to `0000000000267eeb000000000000000000000000000000000000000000000000`. After executing the computation, it can be seen that the resulting hash corresponds to `00000000002647462b1abb10059b1f6f363acbc93f581cc256cc208e0895e5c7`. Since the resulting hash is indeed smaller than the target value, the block can be considered valid. Finally, to further illustrate the scenario, if the `nonce` value above is changed to, say, `0x84214801`, it can be seen that the resulting hash becomes a very large number, as expected - in this case, `3fc9f917be74f50bafc9bad28bf9ccda3e0c46b4af2e5bc78029926460f9100a`.

An identical procedure can be done for a Litecoin block, for example [LTC block #1881577](https://chainz.cryptoid.info/ltc/block.dws?1881577.htm). In this case, we have the following block header values:

```
bytes4 version = 0x20000000;
bytes32 prevBlock = 0xb417303fb9ac36d8323050124d7298827e1da58cd1f66cb8d0aea8caf37d9095;
bytes32 merkleRootHash = 0x3e17b9b078117ea1f51bd0f8ac9a346cb99ee0bc97c97fa93d7d789311f442e9;
bytes4 timestamp = 0x5f189264;         // 2020-07-22 19:24:20, which is timestamp 1595445860 in decimal
bytes4 difficultyBits = 0x1a01cd2d;
bytes4 nonce = 0x84dd91a8;
```

Here, the target value corresponds to `00000000000001cd2d0000000000000000000000000000000000000000000000` and the computed hash can be seen to be `00000000000000ae7e1ecb9956e719cd7234d9f14176e2f53451553c8241bc58`, which also indicates a valid block.


## Building C code

This tutorial DApp can be run using the pre-built `scrypt-hash.ext2` file, which contains a file-system including the `scrypt-hash` application written in C. This application uses the [libscrypt](https://github.com/technion/libscrypt) library in order to compute the hash of the provided input, employing the appropriate parameters as defined by the Litecoin specification.

In order to build this file-system directly from the C code, there are a couple of steps that need to be performed.

First of all, download the [libscrypt](https://github.com/technion/libscrypt) C library, which implements the `scrypt` algorithm. Here, we will clone its code inside the tutorial's `cartesi-machine` directory:

```
$ cd cartesi-machine
$ git clone git@github.com:technion/libscrypt.git
```

Then, build the library targeting Cartesi Machine's RISC-V ISA:

```
$ ./build-libscrypt-riscv64.sh
```

After the library is ready, build the `scrypt-hash` application and pack it inside an `ext2` file-system, so that it is available to the Cartesi Machine:

```
$ ./build-scrypt-hash.sh
```

Finally, it is possible to build the Cartesi Machine itself like the other tutorials, indicating the target directory where it should be stored:

```
$ ./build-cartesi-machine.sh ../../compute-env/machines/
```

> **NOTE**: as noted in the [documentation](https://docs.cartesi.io/machine/host/cmdline#flash-drives), the `genext2fs` command used to generate `ext2` file-systems is *non-reproducible*, meaning that the resulting hash of the stored Cartesi Machine template will differ each time a new `ext2` file is used, even if its contents are identical. Because of this, the template hash must be appropriately updated in the [DogecoinHash.sol](./contracts/DogecoinHash.sol) smart contract whenever a new `ext2` file is used.
