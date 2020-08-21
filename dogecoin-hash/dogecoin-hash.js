/**
 * Truffle script to execute contract methods.
 * 
 * Usage:
 * truffle exec <script.js> -m <method> -i <index>
 */

const contract = require("@truffle/contract");
const program = require("commander");

const contractAbstraction = contract(require("./build/contracts/DogecoinHash.json"));

program
    .option('-m, --method <method>', 'Specify the method to use (mandatory)')
    .option('-i, --index <index>', 'Specify the index to use (optional, ignores for "instantiate" method, default in other cases is index 0)', 0)

module.exports = async (callback) => {
    program.parse(process.argv);

    try {
        if (!program.method) {
            throw "ERROR: required option '-m, --method <method>' not specified\n";
        }
    
        contractAbstraction.setNetwork(web3.eth.net.getId());
        contractAbstraction.setProvider(web3.currentProvider);
        let contractDeployed = await contractAbstraction.deployed();
        let accounts = await web3.eth.getAccounts();

        console.log("Executing method '" + program.method + (program.method == "instantiate" ? "'\n" : "' with index '" + program.index + "'\n"));

        switch (program.method) {
            case "instantiate":
                ret = await contractDeployed.instantiate(accounts[0], accounts[1], { from: accounts[0] });
                console.log("Instantiaton successfull with index '" + web3.utils.toDecimal(ret.receipt.rawLogs[0].data) + "' (tx: " + ret.tx + " ; blocknumber: " + ret.receipt.blockNumber + ")\n");
                break;

            case "getResult":
                ret = await contractDeployed.getResult(program.index);
                console.log("Full result: " + JSON.stringify(ret));
                if (ret["3"]) {
                    console.log("Result value as string: " + web3.utils.hexToAscii(ret["3"]));
                }
                console.log("");
                break;

            case "destruct":
                ret = await contractDeployed.destruct(program.index, { from: accounts[0] });
                console.log("Destructing: " + JSON.stringify(ret) + ")\n");
                break;

            default:
                throw "ERROR: unknown method '" + program.method + "'\n";
        }

        callback();

    } catch (e) {
        callback(e);
    }
};
