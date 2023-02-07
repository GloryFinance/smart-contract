// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";


contract GloryToken is ERC20PresetMinterPauserUpgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 public constant  MAX_SUPPLY = 150000000 * 10 ** 18;

    uint256 public constant  MAX_SUPPLY_PUBLIC = 135000000 * 10 ** 18;

    uint256 public constant  MAX_SUPPLY_TEAM = 15000000 * 10 ** 18;

    uint256 public constant TIME_MINT_TO_TEAM = 1707238111;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    bytes32 public constant OPERATOR_TEAM = keccak256("OPERATOR_TEAM");

    mapping(address => bool) private dexes;


    function initialize()
    public
    initializer
    {
        __ERC20PresetMinterPauser_init("Glory", "GLR");
    }

    function mint(address to, uint256 amount) public virtual override {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "must have operator role"
        );
        require(super.totalSupply() + amount < MAX_SUPPLY, "Total supply over max supply");
        super.mint(to, amount);
    }

    function mintToTeam(address to) public {
        require(
            hasRole(OPERATOR_TEAM, _msgSender()),
            "must have operator role"
        );
        require(block.timestamp >= TIME_MINT_TO_TEAM, "Time mint invalid");

        mint(to, MAX_SUPPLY_TEAM);
    }


    function _mint(address to, uint256 amount) public {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "must have operator role"
        );
        require(super.totalSupply() + amount < MAX_SUPPLY_PUBLIC, "Total supply over max supply public");
        mint(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool){
        if (dexes[from]) {
            uint256 balanceOf = super.balanceOf(from);
            require(amount <= balanceOf, "Balance not enough");
            uint256 amountTransfer = amount.mul(99).div(100);
            uint256 amountFee = amount.sub(amountTransfer);
            super.transfer(address(this), amountFee);
            return super.transferFrom(from, to, amountTransfer);
        } else if (dexes[to]) {
            uint256 balanceOf = super.balanceOf(from);
            uint256 amountFee = amount.div(100);
            require(amount.add(amountFee) <= balanceOf, "Balance not enough");
            super.transfer(address(this), amountFee);
            return super.transferFrom(from, to, amount);
        } else {
            return super.transferFrom(from, to, amount);
        }
    }


    function addDexAddress(address dex) external {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "must have operator role"
        );
        dexes[dex] = true;
    }


}