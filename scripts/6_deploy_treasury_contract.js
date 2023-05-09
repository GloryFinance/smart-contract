const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    const gloryTreasuryFactory = await ethers.getContractFactory("GloryTreasury");
    // TODO input token glory
    const deployTx = await gloryTreasuryFactory.deploy('0x1fc71fE3e333d5262828f3d348C12c7E52306B8A')
    await deployTx.deployed()
    console.log("Treasury address", deployTx.address)
    await verifyContract(deployTx.address, ['0x1fc71fE3e333d5262828f3d348C12c7E52306B8A'])
}

main();
