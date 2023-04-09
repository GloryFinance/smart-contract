// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.5;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libraries/DSMath.sol";
import "./libraries/LogExpMath.sol";
import "./interfaces/IWhitelist.sol";
import "./interfaces/IStakingManager.sol";
import "./interfaces/IGGlory.sol";
import "./VeERC20Upgradeable.sol";

interface IG {
    function vote(address user, int256 voteDelta) external;
}

/// @title GGlory
contract GGlory is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    VeERC20Upgradeable,
    IGGlory,
    IG
{
    using SafeERC20 for IERC20;
    using DSMath for uint256;

    uint256 constant WAD = 1e18;

    /// @notice the glory token
    IERC20 public glory;

    /// @notice the stakingManager contract
    IStakingManager public stakingManager;

    /// @notice whitelist wallet checker
    /// @dev contract addresses are by default unable to stake glory, they must be previously whitelisted to stake glory
    IWhitelist public whitelist;

    uint32 maxBreedingLength;
    uint32 minLockDays;
    uint32 maxLockDays;

    /// @notice user info mapping
    mapping(address => UserInfo) internal users;

    /// @notice Address of the Voter contract
    address public voter;
    /// @notice amount of vote used currently for each user
    mapping(address => uint256) public usedVote;

    event Enter(
        address addr,
        uint256 unlockTime,
        uint256 gloryAmount,
        uint256 gGloryAmount
    );
    event Exit(
        address addr,
        uint256 unlockTime,
        uint256 gloryAmount,
        uint256 gGloryAmount
    );
    event SetStakingManager(address addr);
    event SetVoter(address addr);
    event SetWhiteList(address addr);
    event SetMaxBreedingLength(uint256 len);
    event UpdateLockTime(
        address addr,
        uint256 slot,
        uint256 unlockTime,
        uint256 gloryAmount,
        uint256 originalGGloryAmount,
        uint256 newGGloryAmount
    );

    error GGLORY_OVERFLOW();

    modifier onlyVoter() {
        require(msg.sender == voter, "GGlory: caller is not voter");
        _;
    }

    function initialize(
        IERC20 _glory,
        IStakingManager _stakingManager
    ) external initializer {
        require(address(_stakingManager) != address(0), "zero address");
        require(address(_glory) != address(0), "zero address");

        // Initialize gGlory
        __ERC20_init("Governance Glory", "gGlory");
        __Ownable_init();
        __ReentrancyGuard_init_unchained();
        __Pausable_init_unchained();

        stakingManager = _stakingManager;
        glory = _glory;

        // Note: one should pay attention to storage collision
        maxBreedingLength = 10000;
        minLockDays = 7;
        maxLockDays = 1461;
    }

    function _verifyVoteIsEnough(address _user) internal view {
        require(
            balanceOf(_user) >= usedVote[_user],
            "GGlory: not enough vote"
        );
    }

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice sets stakingManager address
    /// @param _stakingManager the new stakingManager address
    function setStakingManager(
        IStakingManager _stakingManager
    ) external onlyOwner {
        require(address(_stakingManager) != address(0), "zero address");
        stakingManager = _stakingManager;
        emit SetStakingManager(address(_stakingManager));
    }

    /// @notice sets voter contract address
    /// @param _voter the new NFT contract address
    function setVoter(address _voter) external onlyOwner {
        require(address(_voter) != address(0), "zero address");
        voter = _voter;
        emit SetVoter(_voter);
    }

    /// @notice sets whitelist address
    /// @param _whitelist the new whitelist address
    function setWhitelist(IWhitelist _whitelist) external onlyOwner {
        require(address(_whitelist) != address(0), "zero address");
        whitelist = _whitelist;
        emit SetWhiteList(address(_whitelist));
    }

    function setMaxBreedingLength(
        uint256 _maxBreedingLength
    ) external onlyOwner {
        if (_maxBreedingLength > type(uint32).max) revert GGLORY_OVERFLOW();
        maxBreedingLength = uint32(_maxBreedingLength);
        emit SetMaxBreedingLength(_maxBreedingLength);
    }

    function setMinLockDays(uint256 _newMinLockDays) external onlyOwner {
        minLockDays = uint32(_newMinLockDays);
    }

    function setMaxLockDays(uint256 _newMaxLockDays) external onlyOwner {
        maxLockDays = uint32(_newMaxLockDays);
    }

    /// @notice checks wether user _addr has glory staked
    /// @param _addr the user address to check
    /// @return true if the user has glory in stake, false otherwise
    function isUser(address _addr) external view override returns (bool) {
        return balanceOf(_addr) > 0;
    }

    /// @notice return the amount of Glory locked and gGlory acquired by a user
    function getUserOverview(
        address _addr
    )
        external
        view
        override
        returns (uint256 gloryLocked, uint256 gGloryBalance)
    {
        UserInfo storage user = users[_addr];
        uint256 len = user.breedings.length;
        for (uint256 i = 0; i < len; i++) {
            gloryLocked += user.breedings[i].gloryAmount;
        }
        gGloryBalance = balanceOf(_addr);
    }

    /// @notice return the user info
    function getUserInfo(
        address addr
    ) external view override returns (Breeding[] memory) {
        return users[addr].breedings;
    }

    /// @notice return the user info
    function getPoolData(
        address addr
    ) external view returns (Breeding memory, uint256) {
        uint256 totalUnlockedGlory;
        UserInfo memory userInfo = users[addr];
        uint256 upcomingUnlockTime;
        uint256 upcomingUnlockIndex;
        for (uint i = 0; i < userInfo.breedings.length; i++) {
            Breeding memory breeding = userInfo.breedings[i];
            if (breeding.unlockTime <= block.timestamp) {
                totalUnlockedGlory += breeding.gloryAmount;
            } else {
                if (
                    breeding.unlockTime < upcomingUnlockTime ||
                    upcomingUnlockTime == 0
                ) {
                    upcomingUnlockTime = breeding.unlockTime;
                    upcomingUnlockIndex = i;
                }
            }
        }
        return (userInfo.breedings[upcomingUnlockIndex], totalUnlockedGlory);
    }

    /// @dev explicity override multiple inheritance
    function totalSupply()
        public
        view
        override(VeERC20Upgradeable, IGGlory)
        returns (uint256)
    {
        return super.totalSupply();
    }

    /// @dev explicity override multiple inheritance
    function balanceOf(
        address account
    ) public view override(VeERC20Upgradeable, IGGlory) returns (uint256) {
        return super.balanceOf(account);
    }

    function _expectedGGloryAmount(
        uint256 amount,
        uint256 lockDays
    ) internal pure returns (uint256) {
        // gGlory = Glory * 0.026 * lockDays^0.5
        return
            amount.wmul(26162237992630200).wmul(
                LogExpMath.pow(lockDays * WAD, 50e16)
            );
    }

    /// @notice lock Glory into contract and mint gGlory
    function mint(
        uint256 amount,
        uint256 lockDays
    )
        external
        virtual
        override
        nonReentrant
        whenNotPaused
        returns (uint256 gGloryAmount)
    {
        require(amount > 0, "amount to deposit cannot be zero");
        if (amount > uint256(type(uint104).max)) revert GGLORY_OVERFLOW();

        // assert call is not coming from a smart contract
        // unless it is whitelisted
        _assertNotContract(msg.sender);

        require(
            lockDays >= uint256(minLockDays) &&
                lockDays <= uint256(maxLockDays),
            "lock days is invalid"
        );
        require(
            users[msg.sender].breedings.length < uint256(maxBreedingLength),
            "breed too much"
        );

        uint256 unlockTime = block.timestamp + 86400 * lockDays; // seconds in a day = 86400
        gGloryAmount = _expectedGGloryAmount(amount, lockDays);

        if (unlockTime > uint256(type(uint48).max)) revert GGLORY_OVERFLOW();
        if (gGloryAmount > uint256(type(uint104).max))
            revert GGLORY_OVERFLOW();

        users[msg.sender].breedings.push(
            Breeding(
                uint48(unlockTime),
                uint104(amount),
                uint104(gGloryAmount)
            )
        );

        // Request Glory from user
        glory.safeTransferFrom(msg.sender, address(this), amount);

        // event Mint(address indexed user, uint256 indexed amount) is emitted
        _mint(msg.sender, gGloryAmount);

        emit Enter(msg.sender, unlockTime, amount, gGloryAmount);
    }

    function burn(uint256 slot) external override nonReentrant whenNotPaused {
        uint256 length = users[msg.sender].breedings.length;
        require(slot < length, "wut?");

        Breeding memory breeding = users[msg.sender].breedings[slot];
        require(uint256(breeding.unlockTime) <= block.timestamp, "not yet meh");

        // remove slot
        if (slot != length - 1) {
            users[msg.sender].breedings[slot] = users[msg.sender].breedings[
                length - 1
            ];
        }
        users[msg.sender].breedings.pop();

        glory.transfer(msg.sender, breeding.gloryAmount);

        // event Burn(address indexed user, uint256 indexed amount) is emitted
        _burn(msg.sender, breeding.gGloryAmount);

        emit Exit(
            msg.sender,
            breeding.unlockTime,
            breeding.gloryAmount,
            breeding.gGloryAmount
        );
    }

    /// @notice update the GLORY lock days such that the end date is `now` + `lockDays`
    /// @param slot the gGlory slot
    /// @param lockDays the new lock days (it should be larger than original lock days)
    function update(
        uint256 slot,
        uint256 lockDays
    )
        external
        override
        nonReentrant
        whenNotPaused
        returns (uint256 newGGloryAmount)
    {
        _assertNotContract(msg.sender);

        require(
            lockDays >= uint256(minLockDays) &&
                lockDays <= uint256(maxLockDays),
            "lock days is invalid"
        );

        uint256 length = users[msg.sender].breedings.length;
        require(
            slot < length,
            "slot position should be less than the number of slots"
        );

        uint256 originalUnlockTime = uint256(
            users[msg.sender].breedings[slot].unlockTime
        );
        uint256 originalGloryAmount = uint256(
            users[msg.sender].breedings[slot].gloryAmount
        );
        uint256 originalGGloryAmount = uint256(
            users[msg.sender].breedings[slot].gGloryAmount
        );
        uint256 newUnlockTime = block.timestamp + 1 days * lockDays;
        newGGloryAmount = _expectedGGloryAmount(
            originalGloryAmount,
            lockDays
        );

        if (newUnlockTime > type(uint48).max) revert GGLORY_OVERFLOW();
        if (newGGloryAmount > type(uint104).max) revert GGLORY_OVERFLOW();

        require(
            originalUnlockTime < newUnlockTime,
            "the new end date must be greater than existing end date"
        );
        require(
            originalGGloryAmount < newGGloryAmount,
            "the new gGlory amount must be greater than existing gGlory amount"
        );

        // change unlock time and gGlory amount
        users[msg.sender].breedings[slot].unlockTime = uint48(newUnlockTime);
        users[msg.sender].breedings[slot].gGloryAmount = uint104(
            newGGloryAmount
        );

        _mint(msg.sender, newGGloryAmount - originalGGloryAmount);

        // emit event
        emit UpdateLockTime(
            msg.sender,
            slot,
            newUnlockTime,
            originalGloryAmount,
            originalGGloryAmount,
            newGGloryAmount
        );
    }

    /// @notice asserts address in param is not a smart contract.
    /// @notice if it is a smart contract, check that it is whitelisted
    /// @param _addr the address to check
    function _assertNotContract(address _addr) private view {
        if (_addr != tx.origin) {
            require(
                address(whitelist) != address(0) && whitelist.check(_addr),
                "Smart contract depositors not allowed"
            );
        }
    }

    /// @notice hook called after token operation mint/burn
    /// @dev updates stakingManager
    /// @param _account the account being affected
    /// @param _newBalance the newGGloryBalance of the user
    function _afterTokenOperation(
        address _account,
        uint256 _newBalance
    ) internal override {
        _verifyVoteIsEnough(_account);
        stakingManager.updateFactor(_account, _newBalance);
    }

    function vote(
        address _user,
        int256 _voteDelta
    ) external override onlyVoter {
        if (_voteDelta >= 0) {
            usedVote[_user] += uint256(_voteDelta);
            _verifyVoteIsEnough(_user);
        } else {
            // reverts if usedVote[_user] < -_voteDelta
            usedVote[_user] -= uint256(-_voteDelta);
        }
    }
}
