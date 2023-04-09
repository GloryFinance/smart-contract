const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("../../../my_workspace/lucky-fair/scripts/utils");

async function main() {
    const gloryTreasuryFactory = await ethers.getContractFactory("GloryTreasury");
    const deployTx = await gloryTreasuryFactory.deploy('0x016C6dA8344030605565a01078e13A3274764247')
    await deployTx.deployed()
    console.log("Treasury address", deployTx.address)
    await verifyContract(deployTx.address, ['0x016C6dA8344030605565a01078e13A3274764247'])
}

main();
