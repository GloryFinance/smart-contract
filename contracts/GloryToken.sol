// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";


contract GloryToken is ERC20PresetMinterPauser {
    using SafeMath for uint256;

    uint256 public constant  MAX_SUPPLY = 150000000 * 10 ** 18;

    uint256 public constant  MAX_SUPPLY_PUBLIC = 135000000 * 10 ** 18;

    uint256 public constant  MAX_SUPPLY_TEAM = 15000000 * 10 ** 18;

    uint256 public constant TIME_MINT_TO_TEAM = 1707238111;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    bytes32 public constant OPERATOR_TEAM = keccak256("OPERATOR_TEAM");

    mapping(address => bool) public dexes;

    address public  receiveFeeAddress;

    bool public teamMinted;

    constructor() ERC20PresetMinterPauser("Glory", "GLR") {
        grantRole(OPERATOR_ROLE, msg.sender);
        receiveFeeAddress = msg.sender;
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
        require(!teamMinted, "Team minted");
        require(
            hasRole(OPERATOR_TEAM, _msgSender()),
            "must have operator role"
        );
        require(block.timestamp >= TIME_MINT_TO_TEAM, "Time mint invalid");
        teamMinted = true;
        mint(to, MAX_SUPPLY_TEAM);
    }


    function _mintPublic(address to, uint256 amount) public {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "must have operator role"
        );
        require(super.totalSupply() + amount < MAX_SUPPLY_PUBLIC, "Total supply over max supply public");
        mint(to, amount);
    }

    function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
        if (dexes[sender] || dexes[receiver]) {
            _receiveToken(sender, receiver, amount);
        } else {
            _transfer(sender, receiver, amount);
        }
    }


    function _receiveToken(address from,
        address to,
        uint256 amount) private {
        uint256 balanceOf = super.balanceOf(from);
        require(amount <= balanceOf, "Balance not enough");
        uint256 amountTransfer = amount.mul(99).div(100);
        uint256 amountFee = amount.sub(amountTransfer);
        super._transfer(from, receiveFeeAddress, amountFee);
        super._transfer(from, to, amountTransfer);
    }

    function setReceiveFeeAddress(address _receiveFeeAddress) external {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "must have operator role"
        );
        receiveFeeAddress = _receiveFeeAddress;
    }


    function addDexAddress(address dex) external {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "must have operator role"
        );
        dexes[dex] = true;
    }


}