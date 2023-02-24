const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    // Upgrading
    const gloryICO = await ethers.getContractFactory("GloryICO");
    // const contractArgs = [
    //     '0x1D300d86e54D548014b74F8021B4E5449d3625Cc',
    //     '100000000000000000000',
    //     '5000000000000000000000'
    // ]
    // const upgraded = await upgrades.deployProxy(gloryICO, contractArgs);
    // await upgraded.deployed()
    // console.log('GLORY ICO contract', upgraded.address)
    const upgraded = await upgrades.upgradeProxy('0x084773494a7345811206aF42A4eBb8b221F44A55', gloryICO);
    // await verifyContract(upgraded.deployTransaction)

}

main();
