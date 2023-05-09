const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    // Upgrading
    const bep20Mintable = await ethers.getContractFactory("GloryToken");
    const deployTx = await bep20Mintable.deploy('Glory', 'GLR')
    await deployTx.deployed()
    console.log("Glory address", deployTx.address)
    await verifyContract(deployTx.address, ['Glory', 'GLR'])
}

main();