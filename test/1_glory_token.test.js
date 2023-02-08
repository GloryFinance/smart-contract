const GloryToken = artifacts.require("GloryToken");

contract("GloryToken", (accounts) => {
    it('should mint 1 token for a specific account', async () => {
        const GloryTokenInstance = await GloryToken.deployed();
        await GloryTokenInstance.mint(accounts[1], web3.utils.toBN("1000000000000000000"));
        assert.equal((await GloryTokenInstance.balanceOf(accounts[1])).toString(), "1000000000000000000", "Account 1 hasn't received 1 token yet");
    })
    it('should take 1% fee on dex swapping', async () => {
        const GloryTokenInstance = await GloryToken.deployed();
        //Mint 10 million token
        await GloryTokenInstance.mint(accounts[0], web3.utils.toBN("10000000000000000000000000"));
        //Add dex address
        await GloryTokenInstance.addDexAddress(accounts[3]);
        //Address 3 should be a dex address now
        assert.equal(await GloryTokenInstance.dexes(accounts[3]), true, "Address 3 should be a dex address");
        //Set the fee receive address
        await GloryTokenInstance.setReceiveFeeAddress(accounts[4]);
        //Send 1000 token to dex / Simulate sell transaction
        await GloryTokenInstance.transfer(accounts[3], web3.utils.toBN("1000000000000000000000"));
        //The 'dex' address should have 99%
        assert.equal((await GloryTokenInstance.balanceOf(accounts[3])).toString(), "990000000000000000000", "The 'dex' address hasn't received 99% token yet");
        //The receving fee address should receive 1% token
        assert.equal((await GloryTokenInstance.balanceOf(accounts[4])).toString(), "10000000000000000000", "The receving fee address hasn't received 1% token yet");
    })
})