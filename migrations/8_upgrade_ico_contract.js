const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const GloryAddress = "0xcaFb71154AE3996f6a45b8bD6F9Ff08F94dCcF87";
const GLoryIco = artifacts.require("GloryICO");

module.exports = async function (deployer, network) {
    // console.log("you are deploying with the network: ", network);

    // const newInstance = await upgradeProxy(GloryAddress, GLoryIco, { deployer });
    // console.table({
    //     GLoryIcoContractV2: newInstance.address
    // });
};