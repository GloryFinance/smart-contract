const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("../../../my_workspace/lucky-fair/scripts/utils");

async function main() {
    // Upgrading
    const gloryICO = await ethers.getContractFactory("GloryICO");
    // const contractArgs = [
    //     '0x55d398326f99059fF775485246999027B3197955',
    //     '100000000000000000000',
    //     '5000000000000000000000'
    // ]
    // const upgraded = await upgrades.deployProxy(gloryICO, contractArgs);
    // await upgraded.deployed()
    // console.log('GLORY ICO contract', upgraded.address)
    const upgraded = await upgrades.upgradeProxy('0x650ea02fCd18f8ca86A137dAA9AAb1D735b0d41B', gloryICO);
    // // await verifyContract(upgraded.deployTransaction)

}

main();
