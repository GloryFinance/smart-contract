const { ethers, upgrades } = require("hardhat");
const {verifyContract} = require("./utils");

async function main() {
    const gloryAggregatorFactory = await ethers.getContractFactory("GloryAggregator");
    // TODO config address in initialize
    const contractArgs = [
        // harvest fee
        "0",
        // referral commission rate
        "0",
        // glory address
        "0x1fc71fE3e333d5262828f3d348C12c7E52306B8A",
        // glory referral
        "0x5ACd94C8E095D4425D62FA5943cc02256ce13536",
        // masterChef
        "0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652",
        // cake
        "0x0e09fabb73bd3ade0a17ecc321fd13a19e81ce82",
        // usdt
        "0x55d398326f99059fF775485246999027B3197955",
        // router
        "0x10ED43C718714eb63d5aA57B78B54704E256024E",
        // factory
        "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73"

    ]
    // const instance = await upgrades.deployProxy(gloryAggregatorFactory, contractArgs, {unsafeAllowLinkedLibraries: true});
    // await instance.deployed();
    // const address = instance.address.toString().toLowerCase();
    const upgraded = await upgrades.upgradeProxy("0x3530788b6c14244b4426e13b4f4fd3183d3497fb", gloryAggregatorFactory, {unsafeAllowLinkedLibraries: true});
    // console.log(`glory aggregator address : ${address}`)
}

main();
