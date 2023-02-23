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
    // console.log(upgraded)
    const upgraded = await upgrades.upgradeProxy('0x5031F6B9719B5D0b6E091A5c7d550D4f3FB31134', gloryICO);
    await verifyContract(upgraded.deployTransaction)

}

main();
