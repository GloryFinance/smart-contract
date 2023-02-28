import {BigNumber, ContractFactory} from "ethers";
import {ethers, waffle} from "hardhat";
import {expect, use} from 'chai'
import {BEP20Mintable, GloryICOTest, GloryToken} from "../typeChain";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";

describe("Glory Token", () => {
    let deployer: any;
    let user1: any;
    let user2: any;

    let gloryToken: GloryToken

    function toWei(n: number | string): any {
        return BigNumber.from(ethers.utils.parseEther(n.toString()))
    }

    beforeEach(async () => {
        [deployer, user1, user2] = await ethers.getSigners();

        const gloryTokenFactory = await ethers.getContractFactory('GloryToken')
        gloryToken = (await gloryTokenFactory.deploy('Glory Token', 'GLR')) as unknown as GloryToken
    })

    describe("should mint success", async () => {
        it("should only minted by treasury contract", async () => {
            await gloryToken.setTreasuryAddress(user1.address)
            await expect(gloryToken.mint(deployer.address, toWei(10))).to.be.revertedWith("Only Treasury")
            await gloryToken.connect(user1).mint(user1.address, toWei(10))
            expect((await gloryToken.balanceOf(user1.address)).toString()).eq(toWei(10))
        })

        it("should distribute airdrop success", async () => {
            await gloryToken.distributeAirdrop([deployer.address, user1.address, user2.address], toWei(80000))
            await gloryToken.distributeAirdrop([deployer.address], toWei(10000))

            expect((await gloryToken.balanceOf(deployer.address)).toString()).eq(toWei(90000))
            expect((await gloryToken.balanceOf(user1.address)).toString()).eq(toWei(80000))
            expect((await gloryToken.balanceOf(user2.address)).toString()).eq(toWei(80000))

            await expect(gloryToken.distributeAirdrop([deployer.address], toWei(10000))).to.be.revertedWith("exceeds max airdrop amount")
        })

        it("should distribute whitelist sale success", async () => {
            await gloryToken.distributeWhitelistSale(deployer.address, toWei(5000000))
            await gloryToken.distributeWhitelistSale(user1.address, toWei(5000000))
            await gloryToken.distributeWhitelistSale(user2.address, toWei(5000000))

            expect((await gloryToken.balanceOf(deployer.address)).toString()).eq(toWei(5000000))
            expect((await gloryToken.balanceOf(user1.address)).toString()).eq(toWei(5000000))
            expect((await gloryToken.balanceOf(user2.address)).toString()).eq(toWei(5000000))

            await expect(gloryToken.distributeWhitelistSale(user2.address, toWei(5000000))).to.be.revertedWith("exceeds max whitelist sale amount")
        })
    })

})