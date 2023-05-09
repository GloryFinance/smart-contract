const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    // Upgrading
    const bep20Mintable = await ethers.getContractFactory("PancakePair");
    const deployTx = await bep20Mintable.deploy()
    await deployTx.deployed()
    console.log("USDT address", deployTx.address)
    await verifyContract(deployTx.address, ['Glory Mock', 'GLR'])
}

main();
