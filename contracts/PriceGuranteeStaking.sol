// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view returns (uint[] memory amounts);
}

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

interface AggregatorInterface {
    function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract StakingContract {
    address public admin;
    address public grlTokenAddress;
    address public wethAddress;
    address public uniswapRouterAddress;
    address public ethUsdAggregatorAddress;
    uint256 public constant DECIMALS = 18;

    struct Stake {
        uint256 amount;
        uint256 duration;
        uint256 priceInUsd; // Price of GRL in USD at the time of staking
        uint256 amountInUsd; // USD value of the staked amount
    }
    
    mapping(address => mapping(uint256 => Stake[])) public userStakes;

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
        (,int256 ethUsdPrice,,,) = ethUsdAggregator.latestRoundData();
        require(ethUsdPrice > 0, "Invalid ETH/USD price");

        return uint256(ethUsdPrice);
    }

    function getPriceOfGrlInEth() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = grlTokenAddress;
        path[1] = wethAddress;

        IUniswapV2Router router = IUniswapV2Router(uniswapRouterAddress);
        uint[] memory amounts = router.getAmountsOut(1e9, path); // 1 GRL with 9 decimals

        return amounts[1]; // Amount of WETH in 18 decimals
    }

    function calculatePriceOfGrlInUsd() public view returns (uint256) {
        uint256 ethUsdPrice = getEthToUsdValue();
        uint256 grlEthPrice = getPriceOfGrlInEth();

        return (grlEthPrice * ethUsdPrice) / (10 ** DECIMALS);
    }

    function stake(uint256 amount, uint256 durationInDays) external {
        require(amount > 0, "Invalid amount");
        require(durationInDays % 30 == 0, "Invalid duration");

        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 stakingFee = calculateStakingFee(durationInDays, amount);
        uint256 amountInUsd = ((amount - stakingFee) * grlUsdPrice) / (10 ** DECIMALS);

        // Transfer GRL tokens from user to contract
        // Assuming ERC20 transfer function exists
        IERC20(grlTokenAddress).transferFrom(msg.sender, address(this), amount);

        // Calculate timestamp for staking duration
        uint256 stakingEndTime = block.timestamp + (durationInDays * 1 days);

        // Record stake details
        userStakes[msg.sender][durationInDays].push(
            Stake({
                amount: amount,
                duration: stakingEndTime,
                priceInUsd: grlUsdPrice,
                amountInUsd: amountInUsd
            })
        );

        // Transfer staking fee to admin
        IERC20(grlTokenAddress).transfer(admin, stakingFee);

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

    function unstake(uint256 durationInDays) external {
        require(durationInDays > 0, "Invalid duration");

        Stake[] storage stakes = userStakes[msg.sender][durationInDays];
        require(stakes.length > 0, "No stakes found for the given duration");

        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 currentGrlUsdPrice = stakes[stakes.length - 1].priceInUsd;

        uint256 amountToReturn = 0;
        uint256 usdDifference = currentGrlUsdPrice - grlUsdPrice;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (block.timestamp >= stakes[i].duration) {
                amountToReturn += stakes[i].amount;
                stakes[i].amount = 0;
            }
        }

        if (usdDifference > 0) {
            // Calculate additional GRL to return
            uint256 additionalGrlToReturn = (usdDifference * (10 ** DECIMALS)) /
                currentGrlUsdPrice;
            amountToReturn += additionalGrlToReturn;
        }

        // Transfer GRL tokens back to the user
        // Assuming ERC20 transfer function exists
        // grlToken.transfer(msg.sender, amountToReturn);

        emit Unstaked(msg.sender, amountToReturn);
    }

    function calculateStakingFee(
        uint256 durationInDays,
        uint256 amount
    ) internal pure returns (uint256) {
        uint256 feePercentage = getStakingFeePercentage(durationInDays);
        return (amount * feePercentage) / 10000; // feePercentage is in basis points
    }

    function getStakingFeePercentage(uint256 durationInDays) internal pure returns (uint256) {
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

    function getUserStakes(address user, uint256 durationInDays ) external view returns (Stake[] memory) {
        return userStakes[user][durationInDays];
    }

    function getUserStakingDurations(address user) external view returns (uint256[] memory) {
        uint256[] memory durations = new uint256[](12); // Maximum 12 possible durations (30, 60, ..., 360)
        uint256 index = 0;
        for (uint256 i = 30; i <= 360; i += 30) {
            if (userStakes[user][i].length > 0) {
                durations[index] = i;
                index++;
            }
        }
        // Trim the array to remove unused slots
        assembly { mstore(durations, index) }
        return durations;
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
