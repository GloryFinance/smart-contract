const dotenv = require('dotenv')
dotenv.config()
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");
require("@typechain/hardhat");

module.exports = {
    defaultNetwork: "bsc",

    networks: {
        localhost: {
            url: "http://127.0.0.1:8545"
        },
        hardhat: {
            allowUnlimitedContractSize: true,
        },
        bsc: {
            url: "https://bsc-dataseed.binance.org/",
            chainId: 56,
            accounts: [process.env['BSC_MAINNET_PRIVATE_KEY']],
        },
    },

    solidity: {
        compilers: [
            {
                version: "0.8.6",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ]
    },
    etherscan: {
        apiKey: {
            bsc: 'UXFZRYWHB141CX97CPECWH9V7E9QSPHUF6'
        },
    },
    typechain: {
        outDir: "typeChain",
        target: "ethers-v5",
    },
};

