const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const GloryToken = artifacts.require("GloryToken");
const GloryAirdrop = artifacts.require("GloryAirdrop");

const ADMIN_ADDRESS = '0x6CdD3E867D8E73Ade23d8F74044b123806fF1c3a';
const OPERATOR_ADDRESS = '0x6CdD3E867D8E73Ade23d8F74044b123806fF1c3a';

module.exports = async function (deployer) {
    const instance = await deployProxy(GloryAirdrop, [
        GloryToken.address,
        ADMIN_ADDRESS,
        OPERATOR_ADDRESS
    ], { deployer });

    console.table({
        GloryAirdropContract: instance.address
    });
};