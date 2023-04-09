const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("../../../my_workspace/lucky-fair/scripts/utils");

async function main() {
    const gGloryFactory = await ethers.getContractFactory("GGlory")
    const contractArgs = [
        "0x016c6da8344030605565a01078e13a3274764247",
        "0x94f6bC0865C1dfe13816FE2920e8f86682212542"
    ]
    const instance = await upgrades.deployProxy(gGloryFactory, contractArgs, {unsafeAllowLinkedLibraries: true});
    await instance.deployed();
    const address = instance.address.toString().toLowerCase();
    // const upgraded = await upgrades.upgradeProxy("0xe8bfcf414ca618435467ecd1f7ba2663ef5b62c6", veGloryFactory, {unsafeAllowLinkedLibraries: true});
    console.log(`veGlory address : ${address}`)
}

main()