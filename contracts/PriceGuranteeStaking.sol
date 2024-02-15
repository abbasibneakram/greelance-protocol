// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

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

        Stake storage stakeOfUser = stakes[index];

        uint256 totalAmountToReturn = stakeOfUser.amount;
        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 usdDifference = stakeOfUser.priceInUsd - grlUsdPrice;

        if (usdDifference > 0) {
            // Calculate additional GRL to return
            uint256 additionalGrlToReturn = (usdDifference * (10 ** DECIMALS)) /
                stakeOfUser.priceInUsd;
            totalAmountToReturn += additionalGrlToReturn;
        }

        // Delete the stake from the array
        delete stakes[index];

        // Transfer GRL tokens back to the user
        // Assuming ERC20 transfer function exists
        // grlToken.transfer(msg.sender, totalAmountToReturn);

        emit Unstaked(msg.sender, totalAmountToReturn);
    }

    function calculateStakingFee(
        uint256 durationInDays,
        uint256 amount
    ) internal pure returns (uint256) {
        uint256 feePercentage = getStakingFeePercentage(durationInDays);
        return (amount * feePercentage) / 10000; // feePercentage is in basis points
    }

    function getStakingFeePercentage(
        uint256 durationInDays
    ) internal pure returns (uint256) {
        require(durationInDays % 30 == 0, "Invalid duration");

        if (durationInDays == 30) return 3750; // 3.7500%
        if (durationInDays == 60) return 5625; // 5.6250%
        if (durationInDays == 90) return 7734; // 7.7344%
        if (durationInDays == 120) return 9909; // 9.9097%
        if (durationInDays == 150) return 12000; // 12.0000%
        if (durationInDays == 180) return 13898; // 13.8984%
        if (durationInDays == 210) return 15547; // 15.5475%
        if (durationInDays == 240) return 16931; // 16.9311%
        if (durationInDays == 270) return 18061; // 18.0611%
        if (durationInDays == 300) return 18965; // 18.9652%
        if (durationInDays == 330) return 19677; // 19.6771%
        if (durationInDays == 360) return 20231; // 20.2312%

        revert("Invalid duration");
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
