//// SPDX-License-Identifier: MIT
//
//pragma solidity ^0.8.0;
//
//import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//
//import "../libs/SafeERC20UpgradeableGlory.sol";
//import "../interface/IERC20UpgradeableGlory.sol";
//
//contract GloryICO_Old is Initializable, ContextUpgradeable, OwnableUpgradeable {
//    event Deposit(address indexed sender, uint amount, uint balance);
//    event SubmitTransaction(
//        address indexed owner,
//        uint indexed txIndex,
//        address indexed to,
//        uint value
//    );
//    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
//    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
//    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
//
//    using SafeMathUpgradeable for uint256;
//
//    using SafeERC20Upgradeable for IERC20Upgradeable;
//    IERC20Upgradeable public tokenBUSD;
//
//    using SafeERC20Upgradeable for IERC20Upgradeable;
//    IERC20Upgradeable public tokenUSDT;
//
//    using SafeERC20UpgradeableGlory for IERC20UpgradeableGlory;
//    IERC20UpgradeableGlory public tokenGlory;
//
//    uint256 public startTimeICO;
//    uint256 public endTimeICO;
//    uint256 public totalAmountPerBUSD;
//    uint256 public remainIcoTokenAmount;
//    uint public round;
//
//    uint256 public startTimeWhitelistICO;
//    uint256 public endTimeWhitelistICO;
//
//    AggregatorV3Interface internal priceFeed;
//    address public priceFeedAddress;
//
//    address public adminAddress;
//
//    address[] public owners;
//    mapping(address => bool) public isOwner;
//    uint public numConfirmationsRequired;
//
//    struct Transaction {
//        address to;
//        uint256 value;
//        bool executed;
//        uint numConfirmations;
//    }
//
//    struct CustomerInfo {
//        address customer;
//        uint256 tokenNumber;
//        uint256 usdt;
//        uint256 busd;
//        uint256 totalRound1;
//        uint256 totalRound2;
//        uint256 buyTime;
//        uint256 usdtRound2;
//        uint256 busdRound2;
//    }
//
//    mapping(address => CustomerInfo) public customerInfos;
//
//    uint256 public claimTime;
//
//    mapping(uint => mapping(address => bool)) public isConfirmed;
//
//    mapping(address => bool) isConfirmedWhiteList;
//
//    Transaction[] public transactions;
//
//    mapping(address => bool) isConfirmedWithDraw;
//
//    event WithdrawWhileList(address indexed receiver, uint256 indexed amount);
//
//    modifier onlyOwners() {
//        require(isOwner[msg.sender], "not owner");
//        _;
//    }
//
//    modifier onlyWhiteList() {
//        require(isConfirmedWhiteList[msg.sender], "not whitelist");
//        _;
//    }
//
//    modifier onlyWhiteListWithDraw() {
//        require(isConfirmedWithDraw[msg.sender], "not whitelist withdraw");
//        _;
//    }
//
//    struct UserDeposit {
//        uint256 tokenAmount;
//        uint256 usdt;
//        uint256 busd;
//        uint256 totalAmount;
//    }
//
//    mapping(address => UserDeposit) public userDeposits;
//
//    address[] addressDeposits;
//
//    uint256 totalRoundWhiteList;
//
//    uint256 public startTimeRoundTwo;
//
//    uint256 public endTimeRoundTwo;
//
//    function initialize(
//        uint256 _totalAmountPerBUSD,
//        address _busdContractAddress,
//        address _usdtContractAddress,
//        address _gloryContractAddress,
//        address _priceFeedAddress,
//        address _adminAddress,
//        uint _numConfirmationsRequired,
//        uint256 _claimTime,
//        address[] memory _owners
//    ) public initializer {
//        require(_totalAmountPerBUSD > 0, "invalid rate buy ICO by BUSD");
//        require(
//            _busdContractAddress != address(0),
//            "invalid busd contract address"
//        );
//        require(
//            _usdtContractAddress != address(0),
//            "invalid usdt contract address"
//        );
//        require(
//            _gloryContractAddress != address(0),
//            "invalid Glory contract address"
//        );
//        require(_priceFeedAddress != address(0), "invalid operator address");
//        require(_adminAddress != address(0), "invalid operator address");
//        require(_owners.length > 0, "owners required");
//        require(
//            _numConfirmationsRequired > 0 &&
//                _numConfirmationsRequired <= _owners.length,
//            "invalid number of required confirmations"
//        );
//
//        require(_claimTime > 0, "invalid claimTimer");
//
//        startTimeICO = 2526178756000;
//        endTimeICO = 2526178756001;
//        startTimeWhitelistICO = 2526178756000;
//        endTimeWhitelistICO = 2526178756001;
//        round = 1;
//        totalAmountPerBUSD = _totalAmountPerBUSD;
//
//        tokenBUSD = IERC20Upgradeable(_busdContractAddress);
//        tokenUSDT = IERC20Upgradeable(_usdtContractAddress);
//        tokenGlory = IERC20UpgradeableGlory(_gloryContractAddress);
//
//        priceFeedAddress = _priceFeedAddress;
//        priceFeed = AggregatorV3Interface(_priceFeedAddress);
//
//        adminAddress = _adminAddress;
//        claimTime = _claimTime;
//        remainIcoTokenAmount = 0;
//
//        for (uint i = 0; i < _owners.length; i++) {
//            address owner = _owners[i];
//
//            require(owner != address(0), "invalid owner");
//            require(!isOwner[owner], "owner not unique");
//
//            isOwner[owner] = true;
//            owners.push(owner);
//        }
//
//        numConfirmationsRequired = _numConfirmationsRequired;
//
//        __Ownable_init();
//    }
//
//    modifier onlyAdmin() {
//        require(msg.sender == adminAddress, "Your are not admin");
//        _;
//    }
//
//    function setAdmin(address _adminAddress) external onlyAdmin {
//        require(_adminAddress != address(0), "Cannot be zero address");
//        adminAddress = _adminAddress;
//    }
//
//    function getLatestPrice() public view returns (int256) {
//        (
//            uint80 roundID,
//            int256 price,
//            uint256 startedAt,
//            uint256 timeStamp,
//            uint80 answeredInRound
//        ) = priceFeed.latestRoundData();
//        return price;
//    }
//
//    function buyICOByBUSDWhiteList(
//        uint256 amount
//    ) external payable onlyWhiteList {
//        _preCheckBuyPublicSale(amount);
//        _preCheckTotalAmount(msg.sender, amount);
//
//        uint256 buyAmountToken = amount.mul(totalAmountPerBUSD).div(100);
//        _precheckContractRemainAmount(buyAmountToken);
//        bool transferRes = tokenBUSD.transferFrom(
//            msg.sender,
//            address(this),
//            amount
//        );
//        customerInfos[msg.sender].tokenNumber = customerInfos[msg.sender]
//            .tokenNumber
//            .add(buyAmountToken);
//        customerInfos[msg.sender].busd = customerInfos[msg.sender].busd.add(
//            amount
//        );
//        customerInfos[msg.sender].buyTime = block.timestamp;
//        customerInfos[msg.sender].totalRound1 = customerInfos[msg.sender]
//            .totalRound1
//            .add(amount);
//    }
//
//    function buyICOByUSDTWhiteList(
//        uint256 amount
//    ) external payable onlyWhiteList {
//        _preCheckBuyPublicSale(amount);
//        _preCheckTotalAmount(msg.sender, amount);
//
//        uint256 buyAmountToken = amount.mul(totalAmountPerBUSD).div(100);
//        _precheckContractRemainAmount(buyAmountToken);
//        bool transferRes = tokenUSDT.transferFrom(
//            msg.sender,
//            address(this),
//            amount
//        );
//        customerInfos[msg.sender].tokenNumber = customerInfos[msg.sender]
//            .tokenNumber
//            .add(buyAmountToken);
//        customerInfos[msg.sender].usdt = customerInfos[msg.sender].usdt.add(
//            amount
//        );
//        customerInfos[msg.sender].buyTime = block.timestamp;
//        customerInfos[msg.sender].totalRound1 = customerInfos[msg.sender]
//            .totalRound1
//            .add(amount);
//    }
//
//    function buyICOByUSDT(uint256 amount) external payable {
//        _precheckBuy(amount);
//
//        uint256 buyAmountToken = amount.mul(totalAmountPerBUSD).div(100);
//        _precheckContractRemainAmount(buyAmountToken);
//        bool transferRes = tokenUSDT.transferFrom(
//            msg.sender,
//            address(this),
//            amount
//        );
//        customerInfos[msg.sender].tokenNumber = customerInfos[msg.sender]
//            .tokenNumber
//            .add(buyAmountToken);
//        customerInfos[msg.sender].usdt = customerInfos[msg.sender].usdt.add(
//            amount
//        );
//        customerInfos[msg.sender].buyTime = block.timestamp;
//    }
//
//    function buyICOByBUSD(uint256 amount) external payable {
//        _precheckBuy(amount);
//        uint256 buyAmountToken = amount.mul(totalAmountPerBUSD).div(100);
//        _precheckContractRemainAmount(buyAmountToken);
//        bool transferRes = tokenBUSD.transferFrom(
//            msg.sender,
//            address(this),
//            amount
//        );
//        customerInfos[msg.sender].tokenNumber = customerInfos[msg.sender]
//            .tokenNumber
//            .add(buyAmountToken);
//        customerInfos[msg.sender].busd = customerInfos[msg.sender].busd.add(
//            amount
//        );
//        customerInfos[msg.sender].buyTime = block.timestamp;
//    }
//
//    function depositByBUSD(uint256 amount) external payable {
//        _preCheckBuyRoundTwo(amount);
//        _preCheckTotalAmountRound2(msg.sender, amount);
//
//        uint256 buyAmountToken = amount.mul(totalAmountPerBUSD).div(100);
//        _preCheckLimitBuyRound2(buyAmountToken);
//        _precheckContractRemainAmount(buyAmountToken);
//        totalRoundWhiteList = totalRoundWhiteList.add(buyAmountToken);
//        bool transferRes = tokenBUSD.transferFrom(
//            msg.sender,
//            address(this),
//            amount
//        );
//        userDeposits[msg.sender].tokenAmount = userDeposits[msg.sender]
//            .tokenAmount
//            .add(buyAmountToken);
//        userDeposits[msg.sender].busd = userDeposits[msg.sender].busd.add(
//            amount
//        );
//        userDeposits[msg.sender].totalAmount = userDeposits[msg.sender]
//            .totalAmount
//            .add(amount);
//        addressDeposits.push(msg.sender);
//    }
//
//    function depositByUSDT(uint256 amount) external payable {
//        _preCheckBuyRoundTwo(amount);
//        _preCheckTotalAmountRound2(msg.sender, amount);
//
//        uint256 buyAmountToken = amount.mul(totalAmountPerBUSD).div(100);
//        _preCheckLimitBuyRound2(buyAmountToken);
//        _precheckContractRemainAmount(buyAmountToken);
//        totalRoundWhiteList = totalRoundWhiteList.add(buyAmountToken);
//        bool transferRes = tokenUSDT.transferFrom(
//            msg.sender,
//            address(this),
//            amount
//        );
//        userDeposits[msg.sender].tokenAmount = userDeposits[msg.sender]
//            .tokenAmount
//            .add(buyAmountToken);
//        userDeposits[msg.sender].usdt = userDeposits[msg.sender].usdt.add(
//            amount
//        );
//        userDeposits[msg.sender].totalAmount = userDeposits[msg.sender]
//            .totalAmount
//            .add(amount);
//        addressDeposits.push(msg.sender);
//    }
//
//    function setRemainIcoTokenAmount(
//        uint256 _remainIcoTokenAmount
//    ) external onlyAdmin {
//        require(_remainIcoTokenAmount > 0, "remainIco invalid");
//        remainIcoTokenAmount = _remainIcoTokenAmount;
//    }
//
//    function setPriceFeedAddress(
//        address _priceFeedAddress
//    ) external onlyOwners {
//        require(_priceFeedAddress != address(0), "Cannot be zero address");
//        priceFeedAddress = _priceFeedAddress;
//        priceFeed = AggregatorV3Interface(_priceFeedAddress);
//    }
//
//    function submitTransaction(uint256 _value) public onlyOwners {
//        uint txIndex = transactions.length;
//        transactions.push(
//            Transaction({
//                to: msg.sender,
//                value: _value,
//                executed: false,
//                numConfirmations: 0
//            })
//        );
//
//        emit SubmitTransaction(msg.sender, txIndex, msg.sender, _value);
//    }
//
//    function confirmTransaction(uint _txIndex) public onlyOwners {
//        require(_txIndex < transactions.length, "tx does not exist");
//        require(!transactions[_txIndex].executed, "tx already executed");
//        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
//        Transaction storage transaction = transactions[_txIndex];
//        transaction.numConfirmations += 1;
//        isConfirmed[_txIndex][msg.sender] = true;
//
//        emit ConfirmTransaction(msg.sender, _txIndex);
//    }
//
//    function getRemainIcoTokenAmount() external returns (uint256) {
//        return remainIcoTokenAmount;
//    }
//
//    function claimBUSD(uint _txIndex) public onlyOwners {
//        require(_txIndex < transactions.length, "tx does not exist");
//        require(!transactions[_txIndex].executed, "tx already executed");
//        Transaction storage transaction = transactions[_txIndex];
//
//        require(
//            transaction.numConfirmations >= numConfirmationsRequired,
//            "cannot execute tx"
//        );
//
//        transaction.executed = true;
//        tokenBUSD.transfer(transaction.to, transaction.value);
//
//        emit ExecuteTransaction(transaction.to, _txIndex);
//    }
//
//    function claimUSDT(uint _txIndex) public onlyOwners {
//        require(_txIndex < transactions.length, "tx does not exist");
//        require(!transactions[_txIndex].executed, "tx already executed");
//        Transaction storage transaction = transactions[_txIndex];
//
//        require(
//            transaction.numConfirmations >= numConfirmationsRequired,
//            "can't execute tx"
//        );
//
//        transaction.executed = true;
//        tokenUSDT.transfer(transaction.to, transaction.value);
//
//        emit ExecuteTransaction(transaction.to, _txIndex);
//    }
//
//    function claimToken(uint256 _txIndex) external onlyOwner {
//        require(_txIndex < transactions.length, "tx does not exist");
//        require(!transactions[_txIndex].executed, "tx already executed");
//        Transaction storage transaction = transactions[_txIndex];
//
//        require(
//            transaction.numConfirmations >= numConfirmationsRequired,
//            "can't execute tx"
//        );
//
//        transaction.executed = true;
//        tokenGlory.safeTransfer(transaction.to, transaction.value);
//        emit ExecuteTransaction(transaction.to, _txIndex);
//    }
//
//    function claimTokenCustomer() external {
//        uint256 currentTime = block.timestamp;
//        require(currentTime >= claimTime, "invalid time");
//        address sender = _msgSender();
//        uint256 remainAmountToken = customerInfos[sender].tokenNumber;
//        uint256 remainAmountTokenRound2 = userDeposits[sender].tokenAmount;
//        uint256 total = remainAmountToken.add(remainAmountTokenRound2);
//        require(total > 0, "Token didn't enough");
//        userDeposits[sender].tokenAmount = 0;
//        userDeposits[sender].totalAmount = 0;
//        userDeposits[sender].usdt = 0;
//        userDeposits[sender].busd = 0;
//        customerInfos[sender].tokenNumber = 0;
//        customerInfos[sender].busd = 0;
//        customerInfos[sender].usdt = 0;
//        customerInfos[sender].buyTime = 0;
//        customerInfos[sender].totalRound1 = 0;
//        customerInfos[sender].totalRound2 = 0;
//        tokenGlory.safeTransfer(sender, total);
//    }
//
//    function withdrawBUSDWhitelist() external onlyWhiteListWithDraw {
//        uint256 busd = userDeposits[msg.sender].busd;
//        require(busd > 0, "busd invalid");
//        uint256 buyAmountTokenRound2 = busd.mul(totalAmountPerBUSD).div(100);
//        userDeposits[msg.sender].busd = 0;
//        userDeposits[msg.sender].totalAmount = userDeposits[msg.sender]
//            .totalAmount
//            .sub(busd);
//        userDeposits[msg.sender].tokenAmount = userDeposits[msg.sender]
//            .tokenAmount
//            .sub(buyAmountTokenRound2);
//        tokenBUSD.transfer(msg.sender, busd);
//
//        emit WithdrawWhileList(msg.sender, busd);
//    }
//
//    function withdrawUSDTWhitelist() external onlyWhiteListWithDraw {
//        uint256 usdt = userDeposits[msg.sender].usdt;
//        require(usdt > 0, "busd invalid");
//        uint256 buyAmountTokenRound2 = usdt.mul(totalAmountPerBUSD).div(100);
//        userDeposits[msg.sender].usdt = 0;
//        userDeposits[msg.sender].totalAmount = userDeposits[msg.sender]
//            .totalAmount
//            .sub(usdt);
//        userDeposits[msg.sender].tokenAmount = userDeposits[msg.sender]
//            .tokenAmount
//            .sub(buyAmountTokenRound2);
//        tokenUSDT.transfer(msg.sender, usdt);
//
//        emit WithdrawWhileList(msg.sender, usdt);
//    }
//
//    function setContractToken(address contractToken) external onlyAdmin {
//        tokenGlory = IERC20UpgradeableGlory(contractToken);
//    }
//
//    function setRoundInfo(
//        uint256 _startTimeICO,
//        uint256 _endTimeICO
//    ) external onlyAdmin {
//        require(_startTimeICO < _endTimeICO, "invalid time");
//        startTimeICO = _startTimeICO;
//        endTimeICO = _endTimeICO;
//        round = 3;
//    }
//
//    function setRoundWhiteListInfo(
//        uint256 _startTimeWhitelistICO,
//        uint256 _endTimeWhitelistICO,
//        uint _round
//    ) external onlyAdmin {
//        require(
//            _startTimeWhitelistICO < _endTimeWhitelistICO,
//            "invalid whitelist time"
//        );
//        require(_round > 0, "invalid round");
//        startTimeWhitelistICO = _startTimeWhitelistICO;
//        endTimeWhitelistICO = _endTimeWhitelistICO;
//        round = _round;
//    }
//
//    function setRoundWhiteListInfo(
//        uint256 _startTimeRoundTwo,
//        uint256 _endTimeRoundTwo
//    ) external onlyAdmin {
//        require(
//            _startTimeRoundTwo < _endTimeRoundTwo,
//            "invalid whitelist time"
//        );
//        startTimeRoundTwo = _startTimeRoundTwo;
//        endTimeRoundTwo = _endTimeRoundTwo;
//    }
//
//    function setRound(uint _round) external onlyAdmin {
//        require(_round > 0, "invalid round");
//        round = _round;
//    }
//
//    function setWhiteList(address[] memory whitelist) external onlyAdmin {
//        for (uint256 i = 0; i < whitelist.length; i++) {
//            isConfirmedWhiteList[whitelist[i]] = true;
//        }
//    }
//
//    function setWhiteListWithdraw(
//        address[] memory whitelistWithdraw
//    ) external onlyAdmin {
//        for (uint256 i = 0; i < whitelistWithdraw.length; i++) {
//            isConfirmedWithDraw[whitelistWithdraw[i]] = true;
//        }
//    }
//
//    function deleteWhiteList(address customer) external onlyAdmin {
//        isConfirmedWhiteList[customer] = false;
//    }
//
//    function deleteListWhitelist(address[] memory customer) external onlyAdmin {
//        for (uint256 i = 0; i < customer.length; i++) {
//            isConfirmedWhiteList[customer[i]] = false;
//        }
//    }
//
//    function deleteWhiteListWithdraw(address customer) external onlyAdmin {
//        isConfirmedWithDraw[customer] = false;
//    }
//
//    function deleteListWhitelistWithdraw(
//        address[] memory customer
//    ) external onlyAdmin {
//        for (uint256 i = 0; i < customer.length; i++) {
//            isConfirmedWithDraw[customer[i]] = false;
//        }
//    }
//
//    function setTotalAmountPerBUSD(
//        uint256 _totalAmountPerBUSD
//    ) external onlyAdmin {
//        require(_totalAmountPerBUSD > 0, "invalid rate buy ICO by BUSD");
//        totalAmountPerBUSD = _totalAmountPerBUSD;
//    }
//
//    function setClaimTime(uint256 _claimTime) external onlyAdmin {
//        claimTime = _claimTime;
//    }
//
//    function revokeConfirmation(uint _txIndex) public onlyOwners {
//        require(_txIndex < transactions.length, "tx does not exist");
//        require(!transactions[_txIndex].executed, "tx already executed");
//        Transaction storage transaction = transactions[_txIndex];
//
//        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
//
//        transaction.numConfirmations -= 1;
//        isConfirmed[_txIndex][msg.sender] = false;
//
//        emit RevokeConfirmation(msg.sender, _txIndex);
//    }
//
//    function getOwners() public view returns (address[] memory) {
//        return owners;
//    }
//
//    function getTransactionCount() public view returns (uint) {
//        return transactions.length;
//    }
//
//    function getLengthDepositList() public view returns (uint256) {
//        return addressDeposits.length;
//    }
//
//    function getAddressPosition(
//        uint256 position
//    ) public view returns (address) {
//        return addressDeposits[position];
//    }
//
//    function getTransaction(
//        uint _txIndex
//    )
//        public
//        view
//        returns (address to, uint value, bool executed, uint numConfirmations)
//    {
//        Transaction storage transaction = transactions[_txIndex];
//
//        return (
//            transaction.to,
//            transaction.value,
//            transaction.executed,
//            transaction.numConfirmations
//        );
//    }
//
//    function _precheckBuy(uint256 amount) internal view {
//        require(amount > 0, "value must be greater than 0");
//        require(block.timestamp >= startTimeICO, "ICO time does not start now");
//        require(block.timestamp <= endTimeICO, "ICO time is expired");
//    }
//
//    function _preCheckBuyPublicSale(uint256 amount) internal view {
//        require(amount > 0, "value must be greater than 0");
//        require(
//            block.timestamp >= startTimeWhitelistICO,
//            "ICO whitelist time does not start now"
//        );
//        require(
//            block.timestamp <= endTimeWhitelistICO,
//            "ICO whitelist  time is expired"
//        );
//    }
//
//    function _preCheckBuyRoundTwo(uint256 amount) internal view {
//        require(amount > 0, "value must be greater than 0");
//        require(
//            block.timestamp >= startTimeRoundTwo,
//            "ICO Round WhileList time does not start now"
//        );
//        require(
//            block.timestamp <= endTimeRoundTwo,
//            "ICO Round whitelist  time is expired"
//        );
//    }
//
//    function _preCheckTotalAmountRound2(
//        address customer,
//        uint256 amount
//    ) internal view {
//        uint256 total = userDeposits[customer].totalAmount;
//        require(
//            total.add(amount).div(10 ** 18) <= 5000,
//            "address holds more than allowed amount"
//        );
//    }
//
//    function _preCheckTotalAmount(address owner, uint256 amount) internal view {
//        uint256 total = 0;
//        if (round == 1) {
//            total = customerInfos[owner].totalRound1;
//        } else if (round == 2) {
//            total = customerInfos[owner].totalRound2;
//        } else if (round == 3) {
//            uint256 totalRound = customerInfos[owner].totalRound1.add(
//                customerInfos[owner].totalRound2
//            );
//            total = customerInfos[owner]
//                .usdt
//                .add(customerInfos[owner].busd)
//                .sub(totalRound);
//        }
//        require(
//            total.add(amount).div(10 ** 18) <= 10000,
//            "address holds more than allowed amount"
//        );
//    }
//
//    function _preCheckLimitBuyRound2(uint256 buyTokenAmount) internal view {
//        require(
//            totalRoundWhiteList.add(buyTokenAmount).div(10 ** 18) <= 6000000,
//            "sold out round whitelist"
//        );
//    }
//
//    function _precheckContractRemainAmount(uint256 amount) internal view {
//        uint256 remainAmountToken = tokenGlory.balanceOf(address(this));
//        require(
//            remainIcoTokenAmount.add(amount) <= remainAmountToken,
//            "The contract does not enough amount token to buy"
//        );
//    }
//}
