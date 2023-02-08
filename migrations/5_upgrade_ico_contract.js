const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const GloryAddress = "0xC4f7001Dc5Ba4d39B28C0706B05b11dA97a95e0b";
const GLoryIco = artifacts.require("GloryICO");

module.exports = async function (deployer, network) {
    console.log("you are deploying with the network: ", network);

    // const newInstance = await upgradeProxy(GloryAddress, GLoryIco, { deployer });
    // console.table({
    //     GLoryIcoContractV2: newInstance.address
    // });
};