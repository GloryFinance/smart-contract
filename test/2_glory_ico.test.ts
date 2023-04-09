import {BigNumber, ContractFactory} from "ethers";
import {ethers, waffle} from "hardhat";
import {expect, use} from 'chai'
import {BEP20Mintable, GloryICO, GloryICOTest} from "../typeChain";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import {MerkleTree} from "merkletreejs";
import keccak256 from "keccak256";
import * as fs from "fs";

describe("Glory ICO", () => {
    let deployer: any;
    let user1: any;
    let user2: any;
    let user3: any;
    let user4: any;

    let gloryICO: GloryICOTest
    let usdt: BEP20Mintable
    let glory: BEP20Mintable

    function toWei(n: number | string): any {
        return BigNumber.from(ethers.utils.parseEther(n.toString()))
    }

    beforeEach(async () => {
        [deployer, user1, user2, user3, user4] = await ethers.getSigners();

        const bep20MintableFactory = await ethers.getContractFactory('BEP20Mintable')
        usdt = (await bep20MintableFactory.deploy('USDT Mock', 'USDT')) as unknown as BEP20Mintable

        glory = (await bep20MintableFactory.deploy('Glory', 'GLR')) as unknown as BEP20Mintable

        let gloryICOFactory = await ethers.getContractFactory('GloryICOTest')
        gloryICO = (await gloryICOFactory.deploy()) as unknown as GloryICOTest;
        await gloryICO.initialize(usdt.address, toWei(100), toWei(5000))

        await usdt.mint(deployer.address, toWei(100000000))
        await usdt.approve(gloryICO.address, toWei(10000000000))
    })

    describe("should register for whitelist correctly", async () => {
        it("should got revert with invalid registration ", async () => {
            await gloryICO.updateStatusTime(5, 10, 15, 20, 25)
            await gloryICO.setMockTimestamp(3)
            await expect(gloryICO.registerForWhitelist(toWei(110))).to.be.revertedWith('only in register time')
            await gloryICO.setMockTimestamp(6)
            console.log((await gloryICO.getStatus()).toString())
            await expect(gloryICO.registerForWhitelist(toWei(80))).to.be.revertedWith('invalid register amount')
            await gloryICO.registerForWhitelist(toWei(500))
            await expect(gloryICO.registerForWhitelist(toWei(4600))).to.be.revertedWith('over maximum deposit amount')

        })

        it("should register success when reach register time", async () => {
            await gloryICO.updateStatusTime(5, 10, 15, 20, 25)
            await gloryICO.setMockTimestamp(6)
            await gloryICO.registerForWhitelist(toWei('500'))
            console.log((await gloryICO.getDepositedAmount(deployer.address)).toString())
            expect((await gloryICO.getDepositedAmount(deployer.address)).toString()).eq(toWei('500'))
            await gloryICO.registerForWhitelist(toWei('700'))
            expect((await gloryICO.getDepositedAmount(deployer.address)).toString()).eq(toWei('1200'))
        })
    })

    describe("set whitelist and verify whitelist", async () => {
        it("should set merkle root and verify whitelist address success", async () => {
            let whitelistAddress;
            try {
                whitelistAddress = fs.readFileSync('./whitelistAddresses.txt', 'utf8').toString().split("\n")
            }catch (err) {
                console.log(err)
            }
            const leafNodes = whitelistAddress.map(addr => keccak256(addr))
            const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs: true})
            const buf2hex = x => '0x'+x.toString('hex')
            const rootHash = merkleTree.getRoot()
            console.log("root", buf2hex(rootHash))
            // await gloryICO.setMerkleRoot(rootHash)
            const proof = merkleTree.getHexProof(keccak256("0x054E82B00098da1B1411Db47803d38178C49cac1"));
            console.log("proof", proof)
            console.log((await gloryICO.isWhitelistWinner(proof, user1.address)))

            expect((await gloryICO.isWhitelistWinner(proof, user1.address))).eq(true)
        })
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
        await gloryICO.setMockTimestamp(newBlock.timestamp)
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
        await gloryICO.setMockTimestamp(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(2);
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
        await gloryICO.setMockTimestamp(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(4);
    });

    it("should update close time successfully", async function () {
        let provider = ethers.provider;
        const blockNumber = await provider.getBlockNumber();
        const block = await provider.getBlock(blockNumber);
        const timestamp = block.timestamp;
        await gloryICO.connect(deployer).updateClosePurchaseTime(timestamp);
         // Skip a block by mining an empty block
        await provider.send("evm_mine", [timestamp + 13]);
        console.log(await gloryICO.statusData());
        const newBlock = await provider.getBlock(await provider.getBlockNumber());
        console.log(newBlock.timestamp)
        await gloryICO.setMockTimestamp(newBlock.timestamp)
        expect(await gloryICO.getStatus()).to.equal(3);
    });
    
})