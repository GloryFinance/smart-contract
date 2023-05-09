const { ethers, upgrades } = require("hardhat")
const {verifyContract} = require("./utils")

async function main() {
    // Upgrading
    const gloryLockedFactory = await ethers.getContractFactory("GloryLocked")
    const deployTx = await gloryLockedFactory.deploy(
        // glory token address
        '0x1fc71fE3e333d5262828f3d348C12c7E52306B8A',
        // gGlory address
        '0x0d7bb61777063957f18f5920105fa23224679c22'
    )
    await deployTx.deployed()
    console.log("Glory Locked address", deployTx.address)
    await verifyContract(deployTx.address, [
        '0x1fc71fE3e333d5262828f3d348C12c7E52306B8A',
        '0x0d7bb61777063957f18f5920105fa23224679c22'
    ])
}

main()