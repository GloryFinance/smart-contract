// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";

contract GloryICO is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event Registered(address user, uint256 amount);
    event Purchased(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event Distributed(address user, uint256 amount);

    enum Status {
        Register,
        CloseRegister,
        Purchase,
        ClosePurchase,
        Distribute,
        NotActive
    }

    struct UserInfo {
        uint256 depositedAmount;
        address receiver;
        bool hasPurchased;
    }

    struct StatusData {
        uint64 registerTime;
        uint64 closeRegisterTime;
        uint64 purchaseTime;
        uint64 closePurchaseTime;
        uint256 distributeTime;
    }

    /**
     * @notice Merkle root hash for whitelist addresses
     */
    bytes32 public merkleRoot;

    address public constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    IERC20Upgradeable public usdt;
    IERC20Upgradeable public glory;
    uint256 public minimumDepositAmount;
    uint256 public maximumDepositAmount;
    StatusData public statusData;

    mapping(address => UserInfo) public userInfos;

    modifier onlyRegisterTime() {
        require(_isRegisterTime(), "only in register time");
        _;
    }

    modifier onlyCloseRegisterTime() {
        require(_isCloseRegisterTime(), "only in close register time");
        _;
    }

    modifier onlyAfterPurchaseTime() {
        require(_isAfterPurchaseTime(), "only after whitelist result");
        _;
    }

    modifier onlyPurchaseTime() {
        require(_isPurchaseTime(), "only in purchase time");
        _;
    }

    modifier onlyClosePurchaseTime() {
        require(_isClosePurchaseTime(), "only in close purchase time");
        _;
    }

    modifier onlyDistributeTime() {
        require(_isDistributeTime(), "only in distribute time");
        _;
    }

    function initialize(
        address _usdtToken,
        uint256 _minimumDepositAmount,
        uint256 _maximumDepositAmount
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        usdt = IERC20Upgradeable(_usdtToken);
        minimumDepositAmount = _minimumDepositAmount;
        maximumDepositAmount = _maximumDepositAmount;
    }

    function registerForWhitelist(
        uint256 _usdAmount
    ) external nonReentrant onlyRegisterTime {
        require(_usdAmount >= minimumDepositAmount, "invalid register amount");
        address userAddress = msg.sender;
        usdt.safeTransferFrom(userAddress, address(this), _usdAmount);
        userInfos[userAddress].depositedAmount += _usdAmount;
        require(
            userInfos[userAddress].depositedAmount <= maximumDepositAmount,
            "over maximum deposit amount"
        );
        emit Registered(userAddress, _usdAmount);
    }

    function purchase(
        uint256 _usdAmount,
        address _receiver,
        bytes32[] calldata _merkleProof
    ) external nonReentrant onlyPurchaseTime {
        address userAddress = msg.sender;
        require(
            isWhitelistWinner(_merkleProof, userAddress),
            "has not won whitelist"
        );
        require(!userInfos[userAddress].hasPurchased, "already purchased");
        usdt.safeTransferFrom(userAddress, address(this), _usdAmount);
        userInfos[userAddress].depositedAmount += _usdAmount;
        userInfos[userAddress].hasPurchased = true;
        if (_receiver != address(0)) {
            userInfos[userAddress].receiver = _receiver;
        }
        emit Purchased(userAddress, _receiver, _usdAmount);
    }

    function withdraw(
        bytes32[] calldata _merkleProof
    ) external nonReentrant onlyAfterPurchaseTime {
        address userAddress = msg.sender;
        require(
            !isWhitelistWinner(_merkleProof, userAddress),
            "has won whitelist"
        );
        uint256 depositedAmount = userInfos[userAddress].depositedAmount;
        require(depositedAmount != 0, "invalid withdraw amount");
        userInfos[userAddress].depositedAmount = 0;
        usdt.safeTransfer(userAddress, depositedAmount);

        emit Withdraw(userAddress, depositedAmount);
    }

    function ownerWithdrawFund(
        address _token,
        uint256 _amount
    ) external onlyOwner {
        IERC20Upgradeable(_token).safeTransfer(msg.sender, _amount);
    }

    function distributeWhitelist(
        address _receiver,
        uint256 _amount
    ) external onlyOwner {
        require(
            _receiver != address(0) && _amount != 0,
            "invalid distribution"
        );
        glory.safeTransfer(_receiver, _amount);
        emit Distributed(_receiver, _amount);
    }

    function setMerkleRoot(bytes32 merkleRootHash) external onlyOwner {
        merkleRoot = merkleRootHash;
    }

    function updateStatusTime(
        uint64 _registerTime,
        uint64 _closeRegisterTime,
        uint64 _purchaseTime,
        uint64 _closePurchaseTime,
        uint256 _distributeTime
    ) external onlyOwner {
        require(
            _distributeTime > _closePurchaseTime &&
                _closePurchaseTime > _purchaseTime &&
                _purchaseTime > _closeRegisterTime &&
                _closeRegisterTime > _registerTime,
            "invalid time"
        );
        statusData.registerTime = _registerTime;
        statusData.closeRegisterTime = _closeRegisterTime;
        statusData.purchaseTime = _purchaseTime;
        statusData.closePurchaseTime = _closePurchaseTime;
        statusData.distributeTime = _distributeTime;
    }

    function updateRegisterTime(uint64 _registerTime) external onlyOwner {
        statusData.registerTime = _registerTime;
    }

    function updateCloseRegisterTime(
        uint64 _closeRegisterTime
    ) external onlyOwner {
        statusData.closeRegisterTime = _closeRegisterTime;
    }

    function updatePurchaseTime(uint64 _purchaseTime) external onlyOwner {
        statusData.purchaseTime = _purchaseTime;
    }

    function updateClosePurchaseTime(
        uint64 _closePurchaseTime
    ) external onlyOwner {
        statusData.closePurchaseTime = _closePurchaseTime;
    }

    function updateDistributeTime(uint256 _distributeTime) external onlyOwner {
        statusData.distributeTime = _distributeTime;
    }

    function updateGloryAddress(address _gloryToken) external onlyOwner {
        glory = IERC20Upgradeable(_gloryToken);
    }

    function isWhitelistWinner(
        bytes32[] calldata _merkleProof,
        address _user
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_user));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    function getDepositedAmount(
        address _userAddress
    ) public view returns (uint256) {
        return userInfos[_userAddress].depositedAmount;
    }

    // get remaining amount that user can deposit to reach maximum deposit amount
    function getRemainingDepositAmount(
        address _userAddress
    ) public view returns (uint256) {
        return maximumDepositAmount - userInfos[_userAddress].depositedAmount;
    }

    // get current status of the event
    function getStatus() public view returns (Status) {
        StatusData memory memStatusData = statusData;
        if (
            memStatusData.distributeTime != 0 &&
            memStatusData.distributeTime < _now()
        ) {
            return Status.Distribute;
        } else if (
            memStatusData.closePurchaseTime != 0 &&
            memStatusData.closePurchaseTime < _now()
        ) {
            return Status.ClosePurchase;
        } else if (
            memStatusData.purchaseTime != 0 &&
            memStatusData.purchaseTime < _now()
        ) {
            return Status.Purchase;
        } else if (
            memStatusData.closeRegisterTime != 0 &&
            memStatusData.closeRegisterTime < _now()
        ) {
            return Status.CloseRegister;
        } else if (
            memStatusData.registerTime != 0 &&
            memStatusData.registerTime < _now()
        ) {
            return Status.Register;
        }
        return Status.NotActive;
    }

    function _isRegisterTime() internal view virtual returns (bool) {
        return getStatus() == Status.Register;
    }

    function _isCloseRegisterTime() internal view virtual returns (bool) {
        return getStatus() == Status.CloseRegister;
    }

    function _isPurchaseTime() internal view virtual returns (bool) {
        return getStatus() == Status.Purchase;
    }

    function _isClosePurchaseTime() internal view virtual returns (bool) {
        return getStatus() == Status.ClosePurchase;
    }

    function _isDistributeTime() internal view virtual returns (bool) {
        return getStatus() == Status.Distribute;
    }

    function _isAfterPurchaseTime() internal view virtual returns (bool) {
        return _now() > statusData.purchaseTime;
    }

    function _now() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
