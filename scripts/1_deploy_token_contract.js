const { ethers, upgrades } = require("hardhat");

async function main() {
    // Upgrading
    const gloryToken = await ethers.getContractFactory("GloryToken");
    const upgraded = await upgrades.upgradeProxy('0x52494055df871991ee5eab38440d36aeb11f2de2', gloryToken);
    console.log(upgraded)
}

main();
