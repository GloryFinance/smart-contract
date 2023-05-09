const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    const gloryStakingManagerFactory = await ethers.getContractFactory("GloryStakingManager");
    const contractArgs = [
        // glory address
        "0x1fc71fE3e333d5262828f3d348C12c7E52306B8A",
        // glory treasury
        "0x64eFc1f81F41D888FE8e5e196E8926802Eb437AE",
        // gglory
        "0x0d7bb61777063957f18f5920105fa23224679c22",
        // usdt address
        "0x55d398326f99059fF775485246999027B3197955",
        // wbnb address
        "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
        // start block
        "27408037",
        // glory per block
        "95000000000000000",
        // base partition, 500 = 50% reward,
        "500"
    ]
    // const instance = await upgrades.deployProxy(gloryStakingManagerFactory, contractArgs, {unsafeAllowLinkedLibraries: true});
    // await instance.deployed();
    // const address = instance.address.toString().toLowerCase();
    const upgraded = await upgrades.upgradeProxy("0xc4de79d784524f84f23906ae377de53e20fa0d51", gloryStakingManagerFactory, {unsafeAllowLinkedLibraries: true});
    // console.log(`staking manager address : ${address}`)
}

main();
