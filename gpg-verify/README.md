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