# Generic Script Tutorial

This tutorial defines a DApp capable of running an arbitrary script using Descartes.

> **DISCLAIMER**: this is **NOT** the recommended way of implementing a DApp using Descartes. It usually makes no sense to waste resources building a full script on-chain - all possible logic should rather be moved into the off-chain Cartesi Machine. However, this strategy is used here for the purposes of illustrating the potential of Descartes, so as to avoid the need of building a different machine for every script we want to exercise.

## Usage

The DApp's on-chain code will specify a pre-defined script in the form of a string, with a size of up to 1024 bytes. That string must start with a *shebang line* indicating the interpreter to use. It will then be specified as an input drive when executing the Cartesi Machine.

Of course, in order to work, the specified interpreter must be available inside the Cartesi Machine. The current DApp implementation expects the machine to be capable of running commands using `/bin/sh`, `/usr/bin/lua` and `/usr/bin/python3`. Details about how to build the machine with these resources are given [below](#root-file-system-for-the-cartesi-machine).

As it is, the `script` variable in [contracts/GenericScript.sol](contracts/GenericScript.sol) could be any of the following examples:

### Shell

Using `bc` to compute the result of an expression:

```bash
#!/bin/sh
echo '2^71 + 36^12' | bc
```

Result:
```
2365921622773144223744
```

### Lua

Computing `20!` using a recursive factorial function defined in the script itself:

```bash
#!/usr/bin/lua
function fact (n)
    if n <= 0 then
        return 1
    else
        return n * fact(n-1)
    end
end
print(fact(20))
```

Result:
```
2432902008176640000
```

### Python

Using the `pyjwt` lib to decode a JWT token:

```bash
#!/usr/bin/python3
import jwt
payload = jwt.decode(b'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzb21lIjoicGF5bG9hZCJ9.Joh1R2dYzkRvDkqv3sygm5YyK8Gi4ShZqbhK2gxcs2U', 'secret', algorithms=['HS256'])
print(payload)
```

Result:
```javascript
{'some': 'payload'}
```


## Root file-system for the Cartesi Machine

The `build-cartesi-machine.sh` script currently expects a `rootfs-python-jwt.ext2` file to be available. This should correspond to a custom root file-system that includes all the packages of interest. The `sh` and `lua` interpreters are already included in the default root file-system, so for the  examples listed above we would need to include the `python3` interpreter and its `pyjwt` lib.

The process of building a custom `rootfs.ext2` file is [documented here](https://docs.cartesi.io/machine/target/linux#the-root-file-system).

To speed things up, first pull the latest `cartesi/rootfs` Docker image and tag it as `cartesi/rootfs:devel`

```
$ docker pull cartesi/rootfs:latest
$ docker tag cartesi/rootfs:latest cartesi/rootfs:devel
```
 
Then, clone the [machine-emulator-sdk](https://github.com/cartesi/machine-emulator-sdk) repository along with its submodules:

```
$ git clone --recurse-submodules git@github.com:cartesi/machine-emulator-sdk.git
```
or using the http address:
```
$ git clone --recurse-submodules https://github.com/cartesi/machine-emulator-sdk.git
```

Finally, `cd` into the `fs` sub-directory and run `make config` to select the desired packages using a textual menu interface.

For this project, select `Target packages` and then `Interpreter languages and scripting`. Select the `python3` entry, then navigate into `External python modules` and select `python-pyjwt`.

After that, simply exit the configuration interface and answer `y` when prompted to build the root file-system. When the file is built, move it to the project's `cartesi-machine` directory before calling the `build-cartesi-machine.sh` script.


