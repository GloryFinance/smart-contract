// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../ico/GloryICO.sol";

contract GloryICOTest is GloryICO {
    uint256 mockTimestamp;

    function setMockTimestamp(uint256 _mockTimestamp) external {
        mockTimestamp = _mockTimestamp;
    }

    function _now() internal view override returns (uint256) {
        return mockTimestamp;
    }
}