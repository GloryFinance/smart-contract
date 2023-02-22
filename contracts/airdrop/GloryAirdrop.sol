// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interface/IERC20UpgradeableGlory.sol";
import "../libs/SafeERC20UpgradeableGlory.sol";

contract GloryAirdrop is Initializable, ContextUpgradeable, OwnableUpgradeable {
    using SafeERC20UpgradeableGlory for IERC20UpgradeableGlory;
    IERC20UpgradeableGlory public tokenGlory;

    struct Airdrop {
        address userAddress;
        uint256 amount;
    }
    address public operatorAddress;
    address public adminAddress;

    function initialize(
        address _gloryContractAddress,
        address _adminAddress,
        address _operatorAddress
    ) public initializer {
        require(
            _gloryContractAddress != address(0),
            "invalid Glory contract address"
        );
        require(_adminAddress != address(0), "invalid admin address");
        require(_operatorAddress != address(0), "invalid operator address");

        adminAddress = _adminAddress;
        operatorAddress = _operatorAddress;
        tokenGlory = IERC20UpgradeableGlory(_gloryContractAddress);

        __Ownable_init();
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Your are not operator");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Your are not admin");
        _;
    }

    function transferAirdrops(
        Airdrop[] memory arrAirdrop,
        uint256 totalAmount
    ) external onlyOperator {
        for (uint256 i = 0; i < arrAirdrop.length; i++) {
            tokenGlory.transfer(
                arrAirdrop[i].userAddress,
                arrAirdrop[i].amount
            );
        }
    }

    function safeTransferAirdrops(
        Airdrop[] memory arrAirdrop,
        uint256 totalAmount
    ) external onlyOperator {
        for (uint256 i = 0; i < arrAirdrop.length; i++) {
            tokenGlory.safeTransfer(
                arrAirdrop[i].userAddress,
                arrAirdrop[i].amount
            );
        }
    }

    /**
     * @dev set admin address
     * callable by admin
     */
    function setAdmin(address _adminAddress) external onlyAdmin {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;
    }

    function setOperator(address _operatorAddress) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;
    }

    function setContractToken(address contractToken) external onlyOwner {
        tokenGlory = IERC20UpgradeableGlory(contractToken);
    }

    function claimBNB() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken() external onlyAdmin {
        address sender = _msgSender();
        uint256 remainAmountToken = tokenGlory.balanceOf(address(this));
        tokenGlory.safeTransfer(sender, remainAmountToken);
    }

    function _precheckContractAmount(uint256 transferAmount) internal view {
        uint256 remainAmountToken = tokenGlory.balanceOf(address(this));
        require(
            transferAmount <= remainAmountToken,
            "The contract does not enough amount token to buy"
        );
    }
}
