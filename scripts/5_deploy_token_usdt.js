const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    // Upgrading
    const bep20Mintable = await ethers.getContractFactory("BEP20Mintable");
    const deployTx = await bep20Mintable.deploy('Glory Mock', 'GLR')
    await deployTx.deployed()
    console.log("USDT address", deployTx.address)
    await verifyContract(deployTx.address, ['Glory Mock', 'GLR'])
}

main();
