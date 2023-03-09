// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IGloryToken.sol";

contract GloryTreasury is Ownable {

    address public gloryStakingManager;
    IGloryToken public glory;

    uint256 public maxMintAmount = 3_000_000 * 10**18;
    uint256 public baseMintAmount = 1_000_000 * 10**18;

    modifier onlyCounterParty {
        require(gloryStakingManager == msg.sender, "not authorized");
        _;
    }

    constructor(IGloryToken _glory) {
        glory = _glory;
    }

    function myBalance() public view returns (uint256) {
        return glory.balanceOf(address(this));
    }

    function mint(address recipient, uint256 amount) public onlyCounterParty {
        if(myBalance() < amount){
            glory.mint(address(this), baseMintAmount);
        }
        glory.transfer(recipient, amount);
    }

    function setGloryStakingManager(address _newAddress) public onlyOwner {
        gloryStakingManager = _newAddress;
    }

    function setGlory(IGloryToken _newGlory) public onlyOwner {
        glory = _newGlory;
    }

    function setMaxMintAmount(uint256 amount) public onlyOwner {
        maxMintAmount = amount;
    }
}