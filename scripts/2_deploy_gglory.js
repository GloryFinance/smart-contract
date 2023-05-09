const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    const gGloryFactory = await ethers.getContractFactory("GGlory")
    const contractArgs = [
        // glory token address
        "0x1fc71fE3e333d5262828f3d348C12c7E52306B8A",
    ]
    // const instance = await upgrades.deployProxy(gGloryFactory, contractArgs, {unsafeAllowLinkedLibraries: true});
    // await instance.deployed();
    // const address = instance.address.toString().toLowerCase();
    const upgraded = await upgrades.upgradeProxy("0x0d7bb61777063957f18f5920105fa23224679c22", gGloryFactory, {unsafeAllowLinkedLibraries: true});
    // console.log(`veGlory address : ${address}`)
}

main()