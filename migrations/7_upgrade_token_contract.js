const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const GloryTokenAddress = "0xcaFb71154AE3996f6a45b8bD6F9Ff08F94dCcF87";
const GloryContractToken = artifacts.require("GloryToken");

module.exports = async function (deployer, network) {
    console.log("you are deploying with the network: ", network);

    const newInstance = await upgradeProxy(GloryTokenAddress, GloryContractToken, { deployer });
    console.table({
        GLoryIcoContractV2: newInstance.address
    });
};