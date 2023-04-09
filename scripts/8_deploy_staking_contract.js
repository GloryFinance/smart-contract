const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("../../../my_workspace/lucky-fair/scripts/utils");

async function main() {
    const gloryStakingManagerFactory = await ethers.getContractFactory("GloryStakingManager");
    const contractArgs = [
        // glory address
        "0x016c6da8344030605565a01078e13a3274764247",
        // glory treasury
        "0x062Abb87E170615762D5B738a88981f206984616",
        // usdt address
        "0x8545f2473324124c5371F831075A3163AF22f34F",
        // wbnb address
        "0x3B161D6Cc99Ff3c504E71f3910e1546Dce938030",
        "28664244",
        "1000000000000000000"
    ]
    const instance = await upgrades.deployProxy(gloryStakingManagerFactory, contractArgs, {unsafeAllowLinkedLibraries: true});
    await instance.deployed();
    const address = instance.address.toString().toLowerCase();
    // const upgraded = await upgrades.upgradeProxy("0xa50a566a53e3ffaf07db51c2b53f8778a9a17f99", gloryStakingManagerFactory, {unsafeAllowLinkedLibraries: true});
    // console.log(`staking manager address : ${address}`)
}

main();
