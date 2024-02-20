// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view returns (uint[] memory amounts);
}

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
}

contract StakingContract {
    address public admin;
    address public grlTokenAddress;
    address public wethAddress;
    address public uniswapRouterAddress;
    address public ethUsdAggregatorAddress;
    uint256 public constant DECIMALS = 18;

    mapping(uint256 => uint256) public stakingFeePercentage; // Mapping for staking fee percentage against duration in days

    struct Stake {
        uint256 durationInDays;
        uint256 amount;
        uint256 timestamp;
        uint256 priceInUsd; // Price of GRL in USD at the time of staking
        uint256 amountInUsd; // USD value of the staked amount
    }

    mapping(address => Stake[]) public userStakes;

    constructor(
        address _grlTokenAddress,
        address _wethAddress,
        address _uniswapRouterAddress,
        address _ethUsdAggregatorAddress
    ) {
        admin = msg.sender;
        grlTokenAddress = _grlTokenAddress;
        wethAddress = _wethAddress;
        uniswapRouterAddress = _uniswapRouterAddress;
        ethUsdAggregatorAddress = _ethUsdAggregatorAddress;

        // Initialize default staking fee percentages
        stakingFeePercentage[30] = 3750; // 3.7500%
        stakingFeePercentage[60] = 5625; // 5.6250%
        stakingFeePercentage[90] = 7734; // 7.7344%
        // Add more default values as needed
    }

    function setStakingFeePercentage(
        uint256 durationInDays,
        uint256 feePercentage
    ) external onlyAdmin {
        require(durationInDays % 30 == 0, "Invalid duration");
        stakingFeePercentage[durationInDays] = feePercentage;
    }

    function getEthToUsdValue() public view returns (uint256) {
        AggregatorInterface ethUsdAggregator = AggregatorInterface(
            ethUsdAggregatorAddress
        );
        int256 ethUsdPrice = ethUsdAggregator.latestAnswer();
        require(ethUsdPrice > 0, "Invalid ETH/USD price");

        return uint256(ethUsdPrice);
    }

    function getPriceOfGrlInEth() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = grlTokenAddress;
        path[1] = wethAddress;

        IUniswapV2Router router = IUniswapV2Router(uniswapRouterAddress);
        uint[] memory amounts = router.getAmountsOut(1e9, path); // 1 GRL with 9 decimals

        return amounts[1]; // Amount of WETH
    }

    function calculatePriceOfGrlInUsd() public view returns (uint256) {
        uint256 ethUsdPrice = getEthToUsdValue();
        uint256 grlEthPrice = getPriceOfGrlInEth();

        return (grlEthPrice * ethUsdPrice) / (10 ** DECIMALS);
    }

    function stake(uint256 amount, uint256 durationInDays) external {
        require(amount > 0, "Invalid amount");
        require(durationInDays > 0, "Invalid duration");

        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 stakingFee = calculateStakingFee(durationInDays, amount);
        uint256 amountInUsd = (amount * grlUsdPrice) / (10 ** DECIMALS);

        // Transfer GRL tokens from user to contract
        // Assuming ERC20 transfer function exists
        // grlToken.transferFrom(msg.sender, address(this), amount);

        // Calculate timestamp for staking duration
        uint256 stakingEndTime = block.timestamp + (durationInDays * 1 days);

        // Record stake details
        userStakes[msg.sender].push(
            Stake({
                durationInDays: durationInDays,
                amount: amount,
                timestamp: stakingEndTime,
                priceInUsd: grlUsdPrice,
                amountInUsd: amountInUsd
            })
        );

        // Transfer staking fee to admin
        // Assuming ERC20 transfer function exists
        // grlToken.transfer(admin, stakingFee);

        // Emit event
        emit Staked(
            msg.sender,
            amount,
            durationInDays,
            stakingEndTime,
            grlUsdPrice,
            stakingFee,
            amountInUsd
        );
    }

    function unstake(uint256 index) external {
        Stake[] storage stakes = userStakes[msg.sender];
        require(index < stakes.length, "Invalid index");

        Stake storage userStake = stakes[index];

        uint256 totalAmountToReturn = userStake.amount;
        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 usdDifference = userStake.priceInUsd - grlUsdPrice;

        if (usdDifference > 0) {
            // Calculate additional GRL to return
            uint256 additionalGrlToReturn = (usdDifference * (10 ** DECIMALS)) /
                userStake.priceInUsd;
            totalAmountToReturn += additionalGrlToReturn;
        }

        // Transfer GRL tokens back to the user
        // Assuming ERC20 transfer function exists
        // grlToken.transfer(msg.sender, totalAmountToReturn);

        emit Unstaked(msg.sender, totalAmountToReturn);
    }

    function getUserStakeCount(address user) external view returns (uint256) {
        return userStakes[user].length;
    }

    function calculateStakingFee(
        uint256 durationInDays,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 feePercentage = stakingFeePercentage[durationInDays];
        require(feePercentage > 0, "Fee percentage not set for this duration");
        return (amount * feePercentage) / 10000; // feePercentage is in basis points
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 duration,
        uint256 endTime,
        uint256 priceInUsd,
        uint256 fee,
        uint256 amountInUsd
    );
    event Unstaked(address indexed user, uint256 amount);
}
