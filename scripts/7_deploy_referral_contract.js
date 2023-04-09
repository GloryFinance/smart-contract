const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("../../../my_workspace/lucky-fair/scripts/utils");

async function main() {
    const gloryReferralFactory = await ethers.getContractFactory("GloryReferral");
    const deployTx = await gloryReferralFactory.deploy()
    await deployTx.deployed()
    console.log("Referral address", deployTx.address)
    await verifyContract(deployTx.address)
}

main();
