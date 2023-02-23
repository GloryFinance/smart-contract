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

    describe('should initialize success', async () => {
        it('')
    })
})