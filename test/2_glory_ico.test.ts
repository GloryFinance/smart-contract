import {BigNumber, ContractFactory} from "ethers";
import {ethers, waffle} from "hardhat";
import {expect, use} from 'chai'
import {BEP20Mintable, GloryICO} from "../typeChain";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";

describe("Glory ICO", () => {
    let deployer: any;
    let user1: any;
    let user2: any;
    let user3: any;
    let user4: any;

    let gloryICO: GloryICO
    let usdt: BEP20Mintable
    let glory: BEP20Mintable

    beforeEach(async () => {
        [deployer, user1, user2, user3, user4] = await ethers.getSigners();

        const bep20MintableFactory = await ethers.getContractFactory('BEP20Mintable')
        usdt = (await bep20MintableFactory.deploy('USDT Mock', 'USDT')) as unknown as BEP20Mintable

        glory = (await bep20MintableFactory.deploy('Glory', 'GLR')) as unknown as BEP20Mintable

        let gloryICOFactory = await ethers.getContractFactory('GloryICO')
        gloryICO = (await gloryICOFactory.deploy()) as unknown as GloryICO;
        await gloryICO.initialize(usdt.address, 100, 5000)
    })

    it("should update register time successfully", async function () {
        let provider = ethers.provider;
        const blockNumber = await provider.getBlockNumber();
        const block = await provider.getBlock(blockNumber);
        const timestamp = block.timestamp;
        await gloryICO.connect(deployer).updateRegisterTime(timestamp);
         // Skip a block by mining an empty block
        await provider.send("evm_mine", [timestamp + 13]);
        console.log(await gloryICO.statusData());
        const newBlock = await provider.getBlock(await provider.getBlockNumber());
        console.log(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(0);
    });

    it("should update purchase time successfully", async function () {
        let provider = ethers.provider;
        const blockNumber = await provider.getBlockNumber();
        const block = await provider.getBlock(blockNumber);
        const timestamp = block.timestamp;
        await gloryICO.connect(deployer).updatePurchaseTime(timestamp);
         // Skip a block by mining an empty block
        await provider.send("evm_mine", [timestamp + 13]);
        console.log(await gloryICO.statusData());
        const newBlock = await provider.getBlock(await provider.getBlockNumber());
        console.log(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(1);
    });

    it("should update distribute time successfully", async function () {
        let provider = ethers.provider;
        const blockNumber = await provider.getBlockNumber();
        const block = await provider.getBlock(blockNumber);
        const timestamp = block.timestamp;
        await gloryICO.connect(deployer).updateDistributeTime(timestamp);
         // Skip a block by mining an empty block
        await provider.send("evm_mine", [timestamp + 13]);
        console.log(await gloryICO.statusData());
        const newBlock = await provider.getBlock(await provider.getBlockNumber());
        console.log(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(3);
    });

    it("should update close time successfully", async function () {
        let provider = ethers.provider;
        const blockNumber = await provider.getBlockNumber();
        const block = await provider.getBlock(blockNumber);
        const timestamp = block.timestamp;
        await gloryICO.connect(deployer).updateCloseTime(timestamp);
         // Skip a block by mining an empty block
        await provider.send("evm_mine", [timestamp + 13]);
        console.log(await gloryICO.statusData());
        const newBlock = await provider.getBlock(await provider.getBlockNumber());
        console.log(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(2);
    });
    
})