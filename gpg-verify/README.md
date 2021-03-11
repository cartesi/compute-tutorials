# GpgVerify Tutorial

This tutorial DApp uses the [GNU Privacy Guard (GnuPG)](https://www.gnupg.org/) tool to verify that a given document was really signed by the expected party and has not been tampered.


## Usage

The DApp uses two input drives, one for the document and another for its corresponding detached signature. It then runs the standard Linux `gpg` tool within the Cartesi Machine to verify if the signature is indeed valid for that document, returning the tool's exit status. This exit status will be `"0"` for success/no errors (i.e., document is authentic and has not been tampered), `"1"` for failure (i.e., document is either not authentic or has been tampered), and other values for errors such as invalid data.

The committed [GpgVerify.sol](./contracts/GpgVerify.sol) contract contains a fictional document and a corresponding valid signature produced using a [private key](./cartesi-machine/descartes-private.key) created for this tutorial.

```javascript
bytes doc = "My public statement\n";
bytes signature = hex'8901d...a326c';
```

In its turn, the DApp's Cartesi Machine contains the corresponding [public key](./cartesi-machine/descartes-pub.key) for that keypair, and thus works as a trusted verifier for the authenticity of any document signed by that private key.

Please refer to the [GnuPG manual](https://www.gnupg.org/gph/en/manual.html) for details on how to create other keypairs and produce detached signatures. If desired, the provided private key can be used to sign other documents (its passphrase is "Descartes rocks!").

## Usage with Logger

The [GpgVerify.sol](./contracts/GpgVerify.sol) contract includes a method for instantiating the computation using the Merkle root hashes of a document and its corresponding signature.

In order to use it, before calling the instantiation method you should prepare the desired data and make it available to the Logger service. "Preparing the data" basically involves prepending each file with four bytes that encode the content length, which is the format expected by the implemented Cartesi Machine. The Merkle root hashes of the resulting files should then be computed before making the contents available to the Logger service by adding them to a Descartes node's data directory. The [prepend-length.sh](./cartesi-machine/prepend-length.sh) and [logger-add.sh](./cartesi-machine/logger-add.sh) scripts can be used to help in those tasks.

For instance, for the existing [document](./cartesi-machine/document) and [signature](./cartesi-machine/signature) files, you should execute the following commands:

```bash
$ cd cartesi-machine
$ ./prepend-length.sh document document.prepended
$ ./prepend-length.sh signature signature.prepended
```

And then:
```bash
$ ./logger-add.sh document.prepended 10 ../../descartes-env/alice_data
$ ./logger-add.sh signature.prepended 10 ../../descartes-env/alice_data
```

Where the numeral parameter corresponds to the log2 size to be used when computing the Merkle tree of the data (1K in this case, must be at least as large as the data contents). The Merkle root hash will be printed on the screen and also written to corresponding `*.merkle` files. The script will then place the files in the indicated destination data directory, which in this case corresponds to the one for `alice`'s node.

The signature verification can then be instantiated using the configured Hardhat task `instantiate-logger`, providing the appropriate Merkle root hashes and total tree sizes. This will effectively make `alice`'s node publish the data on-chain. To avoid submitting the data to the blockchain, jump to the next section to call another instantiation method which uses IPFS as well.

```bash
$ npx hardhat --network localhost instantiate-logger \
    --docroothash 0x$(cat document.prepended.merkle) \
    --doclog2size 10 \
    --sigroothash 0x$(cat signature.prepended.merkle) \
    --siglog2size 10
```

Alternatively, the [logger-submit.sh](./cartesi-machine/logger-add.sh) script can be used instead of [logger-add.sh](./cartesi-machine/logger-add.sh). This will immediately submit the data directly to the blockchain.

## Usage with IPFS

Instead of performing the above instantiation, an alternative would be to first submit the data to IPFS and then inform the IPFS paths for the document and its corresponding signature. The Merkle root hashes of both files will also be needed and the data should still be available in the Logger service's data directory as before, but if the data is found on IPFS it will not need to be actually submitted to the blockchain.

The [ipfs-submit.sh](./cartesi-machine/ipfs-submit.sh) script can be executed in order to publish the data to IPFS. This script is currently uploading the data to Infura, making it available to be downloaded later on by the Descartes IPFS service running in each node.

For the existing [document](./cartesi-machine/document) and [signature](./cartesi-machine/signature) files, you should execute the following commands:

```bash
$ ./ipfs-submit.sh document.prepended
$ ./ipfs-submit.sh signature.prepended
```
Which will upload the files to IPFS and print on the screen the resulting IPFS hash. The script also writes the resulting hash to a corresponding `*.ipfs` file.

The computation can then be instantiated using the configured Hardhat task `instantiate-ipfs`, providing the desired ipfs paths, logger root hashes and total tree sizes for each drive:

```bash
$ npx hardhat --network localhost instantiate-ipfs \
    --docipfspath /ipfs/$(cat document.prepended.ipfs) \
    --docroothash 0x$(cat document.prepended.merkle) \
    --doclog2size 10 \
    --sigipfspath /ipfs/$(cat signature.prepended.ipfs) \
    --sigroothash 0x$(cat signature.prepended.merkle) \
    --siglog2size 10
```

## Building the Cartesi Machine

In order to run the `gpg` tool to verify a signed document, the DApp's Cartesi Machine will need to have access to the appropriate public key. This is accomplished by including that key in an `ext2` file-system, which is then added to the machine as a flash-drive. In practice, in this tutorial the main script `gpg-verify.sh` is also added to the `ext2` file, for improved readability/organization.

As such, first of all build the `ext2` file inside the `cartesi-machine` directory:

```bash
$ cd cartesi-machine
$ ./build-ext2.sh
```

Then, build the Cartesi Machine itself, as done for the other tutorials, indicating the target directory where it should be stored:

```bash
$ ./build-cartesi-machine.sh ../../descartes-env/machines/
```

> **NOTE**: as of this writing, in order to be reproducible the Cartesi Machine always starts running with timestamp `0` (1970-01-01 UTC). This is inconvenient for this computation, since the `gpg` tool requires the *signature* file's timestamp to be smaller than the current system time. For that purpose, the machine specified in `build-cartesi-machine.sh` sets an appropriate date before calling the main `gpg-verify.sh` script. Finally, keep in mind that changing this date (or any other aspect of the machine's definition) will necessarily change the template hash that should be used to instantiate the Descartes computation within the smart contract.

> **NOTE**: as noted in the [documentation](https://docs.cartesi.io/machine/host/cmdline#flash-drives), the `genext2fs` command used to generate `ext2` file-systems is *non-reproducible*, meaning that the resulting hash of the stored Cartesi Machine template will differ each time a new `ext2` file is used, even if its contents are identical. Because of this, the template hash must be appropriately updated in the [GpgVerify.sol](./contracts/GpgVerify.sol) smart contract whenever a new `ext2` file is used.
