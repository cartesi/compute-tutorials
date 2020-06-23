# Descartes SDK Tutorials

This project contains tutorial DApps implemented with the Descartes SDK, as documented in https://github.com/cartesi-corp/docs

## Getting Started

### Requirements

- docker
- docker-compose
- node 12.x
- yarn
- truffle

### Cloning

```
git clone ssh://github.com/cartesi/descartes-tutorials.git
```
or using the http address:
```
git clone https://github.com/cartesi/descartes-tutorials.git
```

### Running

Each subdirectory contains an independent DApp tutorial. Each tutorial consists of:
- A Smart Contract, along with any dependencies and migrations
- The specification of a Cartesi Machine that performs a computation

The tutorials are currently designed to interact with Descartes Nodes instantiated by running the [Descartes docker-compose](https://github.com/cartesi-corp/descartes/blob/develop/docker-compose-template.yml)

To run each tutorial, first `cd` into its directory. For instance:
```
% cd helloworld
```

Then build the machine by executing:
```
% cd cartesi-machine
% ./build-cartesi-machine.sh
```
This will build the DApp's Cartesi Machine and store it in a subdirectory named after its hash. You should then move this to the appropriate data directories used by the Descartes Nodes (`dapp_data_0` and `dapp_data_1`).

The DApp Smart Contract must be compiled and migrated using the same network where Descartes is deployed (edit `truffle-config.js` if necessary, and make sure `@cartesi/descartes-sdk/build/contracts/Descartes.json` includes the desired network):
```
% yarn
% truffle compile
% truffle migrate
```

Once this is done, the DApp can be tested using `truffle console`. For instance, for the HelloWorld DApp one can use:
```
% truffle console
truffle(development)> let hw = await HelloWorld.deployed()
truffle(development)> hw.instantiate('0xf865DC3d1a10440864515Ec48258356cfa8c3063','0x6a07bc9Aaa4d21092cdb796a73F226E4FB33B0e6')
```

After the computation completes, it will be possible to query the results:
```
truffle(development)> let res = await hw.getResult(0)
truffle(development)> res
Result {
    '0': true,
    '1': false,
    '2': '0x0000000000000000000000000000000000000000',
    '3': '0x48656c6c6f20576f726c64210a00000000000000000000000000000000000000'
}
truffle(development)> web3.utils.toAscii(res['3'])
'Hello World!\n\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
```

## Contributing

Thank you for your interest in Cartesi! Head over to our [Contributing Guidelines](CONTRIBUTING.md) for instructions on how to sign our Contributors Agreement and get started with Cartesi!

Please note we have a [Code of Conduct](CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

