const {deployProxy} = require('@openzeppelin/truffle-upgrades');

// const GloryToken = artifacts.require("GloryToken");

// const GRLOY_TOKEN_ADDRESS = '0xA4FaB88dDC36BBDe770be20F89B7134696173e34'; // Testnet
const GRLOY_TOKEN_ADDRESS = '0x52494055df871991EE5eAb38440d36aeB11f2DE2'; // Mainnet

const GloryICO = artifacts.require("GloryICO");

const CLAIM_TIME = 2526178756000;
const TOTAL_AMOUNT_PER_BUSD = 200;

// BUSD Testnet
// const BUSD_CONTRACT_ADDRESS = '0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee';

// Mainnet address: 0xe9e7cea3dedca5984780bafc599bd69add087d56
const BUSD_CONTRACT_ADDRESS = '0xe9e7cea3dedca5984780bafc599bd69add087d56';

// Testnet USDT-BEP20
// const USDT_CONTRACT_ADDRESS = '0x337610d27c682E347C9cD60BD4b3b107C9d34dDd';

//Mainnet addresss
const USDT_CONTRACT_ADDRESS = '0x55d398326f99059ff775485246999027b3197955';

// because testnet does not have busd/bnb, so for test we use DAI/BNB
const PRICE_FEED_ADDRESS = '0x0630521aC362bc7A19a4eE44b57cE72Ea34AD01c';

// Mainnet 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941
// const PRICE_FEED_ADDRESS = '0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941';
const ADMIN_ADDRESS = '0x246f920A13a41d7868f802e2339A88081389D9DB';

const OWNERS = ['0x246f920A13a41d7868f802e2339A88081389D9DB', '0x19eDcEb07250F22F1f208f6A3EE38b19f36d2f7a'];
const numConfirmationsRequired = 2;

 // GloryToken.address,
module.exports = async function (deployer) {
    const instance = await deployProxy(GloryICO, [
        TOTAL_AMOUNT_PER_BUSD,
        BUSD_CONTRACT_ADDRESS,
        USDT_CONTRACT_ADDRESS,
        GRLOY_TOKEN_ADDRESS,
        PRICE_FEED_ADDRESS,
        ADMIN_ADDRESS,
        numConfirmationsRequired,
        CLAIM_TIME,
        OWNERS
    ], {deployer});

    console.table({
        GloryICOICOContract: instance.address
    });
};