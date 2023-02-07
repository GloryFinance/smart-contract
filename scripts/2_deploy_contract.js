const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const GloryToken = artifacts.require("GloryToken");


module.exports = async function (deployer, network) {
    console.log("you are deploying with the network: ", network);

    const instance = await deployProxy(GloryToken, [], { deployer });

    console.table({
        GloryTokenContract: instance.address
    });
};