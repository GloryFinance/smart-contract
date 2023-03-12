import {BigNumber, ContractFactory} from "ethers";
import {ethers, waffle} from "hardhat";
import {expect, use} from 'chai'
import {BEP20Mintable, GloryICOTest, GloryReferral, GloryStakingManager, GloryToken, GloryTreasury} from "../typeChain";
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";

describe("Glory Token", () => {
    let deployer: any;
    let user1: any;
    let user2: any;

    let lpToken: BEP20Mintable
    let gloryToken: GloryToken
    let gloryTreasury: GloryTreasury
    let gloryStakingManager: GloryStakingManager
    let gloryReferral: GloryReferral

    function toWei(n: number | string): any {
        return BigNumber.from(ethers.utils.parseEther(n.toString()))
    }

    beforeEach(async () => {
        [deployer, user1, user2] = await ethers.getSigners();

        const bep20MintableFactory = await ethers.getContractFactory('BEP20Mintable')
        lpToken = (await bep20MintableFactory.deploy('Glory LP', 'LP')) as unknown as BEP20Mintable

        const gloryTokenFactory = await ethers.getContractFactory('GloryToken')
        gloryToken = (await gloryTokenFactory.deploy('Glory Token', 'GLR')) as unknown as GloryToken

        const gloryTreasuryFactory = await ethers.getContractFactory('GloryTreasury')
        gloryTreasury = (await gloryTreasuryFactory.deploy(gloryToken.address)) as unknown as GloryTreasury

        const gloryStakingManagerFactory = await ethers.getContractFactory('GloryStakingManager')
        gloryStakingManager = (await gloryStakingManagerFactory.deploy(gloryToken.address, gloryTreasury.address, (await ethers.provider.getBlock("latest")).number, toWei(1))) as unknown as GloryStakingManager

        const gloryReferralFactory = await ethers.getContractFactory('GloryReferral')
        gloryReferral = (await gloryReferralFactory.deploy()) as unknown as GloryReferral

        await lpToken.mint(deployer.address, toWei(100000000))
        await lpToken.approve(gloryStakingManager.address, toWei(10000000000))

        await lpToken.mint(user1.address, toWei(100000000))
        await lpToken.connect(user1).approve(gloryStakingManager.address, toWei(10000000000))

        await gloryStakingManager.setGloryReferral(gloryReferral.address)
        await gloryToken.setTreasuryAddress(gloryTreasury.address)
        await gloryTreasury.setGloryStakingManager(gloryStakingManager.address)
    })

    describe("add lp pool and deposit", async () => {
        it("should add lp pool and deposit success", async () => {
            await gloryStakingManager.add(100, lpToken.address, 100, 86400, true)

            await gloryStakingManager.deposit(0, toWei(100), ethers.constants.AddressZero)
        })

        it("should deposit and have earning", async () => {
            await gloryStakingManager.add(100, lpToken.address, 100, 86400, true)

            await gloryStakingManager.connect(user1).deposit(0, toWei(100), ethers.constants.AddressZero)

            console.log((await gloryStakingManager.pendingGlory(0, user1.address)))
            await ethers.provider.send("hardhat_mine", ["0x100"])
            console.log((await gloryStakingManager.pendingGlory(0, user1.address)))
            expect((await gloryStakingManager.pendingGlory(0, user1.address)).toString()).not.eq('0')
        })

        it("should deposit, have earning and harvest success", async () => {
            await gloryStakingManager.add(100, lpToken.address, 100, 1, true)

            await gloryStakingManager.connect(user1).deposit(0, toWei(100), ethers.constants.AddressZero)

            await ethers.provider.send("hardhat_mine", ["0x100"])
            expect((await gloryStakingManager.pendingGlory(0, user1.address)).toString()).eq('255999999999942000000')
            expect((await gloryStakingManager.canHarvest(0, user1.address))).eq(true)
            await gloryStakingManager.connect(user1).deposit(0, 0, ethers.constants.AddressZero)

            // charged fee
            expect((await gloryToken.balanceOf(user1.address)).toString()).eq(BigNumber.from('256999999999941000000'))

            // pending glory reduce to 0
            expect((await gloryStakingManager.pendingGlory(0, user1.address)).toString()).eq('0')

            // locked harvest
            expect((await gloryStakingManager.canHarvest(0, user1.address))).eq(false)
        })
    })
})