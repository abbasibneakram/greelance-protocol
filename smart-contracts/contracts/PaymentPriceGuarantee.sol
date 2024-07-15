// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

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
        address[] calldata path
    ) external view returns (uint[] memory amounts);
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

contract PaymentPriceGuaranteeStakingTest {
    address public admin;
    uint256 public admminFee = 375000;
    address public grlTokenAddress;
    address public wethAddress;
    address public uniswapRouterAddress;
    address public ethUsdAggregatorAddress;
    uint256 private constant DECIMALS = 18;

    uint256 public totalStakedGrl;

    mapping(uint256 => uint256) public stakingFeePercentage; // Mapping for staking fee percentage against duration in days

    struct Stake {
        uint256 amount;
        uint256 stakingTime;
        uint256 priceInUsd; // Price of GRL in USD at the time of staking
        uint256 amountInUsd; // USD value of the staked amount
    }

    mapping(address => Stake[]) public userStakes;
    mapping(address => mapping(uint256 => bool)) public hasUnstaked;

    event Staked(address indexed user, uint256 amount);

    event Unstaked(address indexed user, uint256 amount);

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
        stakingFeePercentage[30] = 375000;
        stakingFeePercentage[60] = 562500;
        stakingFeePercentage[90] = 773440;
        stakingFeePercentage[120] = 990970;
        stakingFeePercentage[150] = 1200000;
        stakingFeePercentage[180] = 1389840;
        stakingFeePercentage[210] = 1554750;
        stakingFeePercentage[240] = 1693110;
        stakingFeePercentage[270] = 1806110;
        stakingFeePercentage[300] = 1896520;
        stakingFeePercentage[330] = 1967710;
        stakingFeePercentage[360] = 2023120;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function setAdminFeePercentage(uint256 feePercentage) external onlyAdmin {
        admminFee = feePercentage;
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
        (, int256 ethUsdPrice, , , ) = ethUsdAggregator.latestRoundData();
        require(ethUsdPrice > 0, "Invalid ETH/USD price");

        return uint256(ethUsdPrice);
    }

    function getPriceOfGrlInEth() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = grlTokenAddress;
        path[1] = wethAddress;

        IUniswapV2Router router = IUniswapV2Router(uniswapRouterAddress);
        uint[] memory amounts = router.getAmountsOut(1e9, path); // 1 GRL with 9 decimals

        return amounts[1]; // Amount of WETH to be divided by 10**18
    }

    function calculatePriceOfGrlInUsd() public view returns (uint256) {
        uint256 ethUsdPrice = getEthToUsdValue();
        uint256 grlEthPrice = getPriceOfGrlInEth();

        return (grlEthPrice * ethUsdPrice) / (10 ** DECIMALS);
    }

    function calculateAdminFee(
        uint256 _amount
    ) internal view returns (uint256) {
        return ((_amount * admminFee) / 10000000);
    }

    function stakeGrl(address _freelancerAddress, uint256 amount) external {
        require(amount > 0, "Invalid amount");

        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 adminFeeAmount = calculateAdminFee(amount);
        require(
            IERC20(grlTokenAddress).transferFrom(
                msg.sender,
                address(this),
                amount + adminFeeAmount
            ),
            "Insufficient Payment!"
        );

        IERC20(grlTokenAddress).transfer(admin, adminFeeAmount);

        uint256 amountInUsd = (amount * grlUsdPrice) / (10 ** 9);

        // Record stake details
        userStakes[_freelancerAddress].push(
            Stake({
                amount: amount,
                stakingTime: block.timestamp,
                priceInUsd: grlUsdPrice,
                amountInUsd: amountInUsd
            })
        );

        //Emit event
        emit Staked(_freelancerAddress, amount);
    }

    function unstake(uint256 index) external {
        require(!hasUnstaked[msg.sender][index], "Stake already unstaked");
        Stake[] storage stakes = userStakes[msg.sender];
        require(index < stakes.length, "Invalid index");

        Stake storage stake = stakes[index];

        // Calculate the time difference in days
        uint256 timeDiff = block.timestamp - stake.stakingTime;
        uint256 daysDiff = timeDiff / (180 seconds);

        uint256 stakingFee = 0;
        if (daysDiff >= 1) {
            stakingFee = calculateStakingFee(daysDiff, stake.amount);
        }

        // Calculate the price difference and adjust the amount to return
        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 usdDifference = stake.priceInUsd - grlUsdPrice;
        if (usdDifference > 0) {
            uint256 additionalGrlToReturn = (usdDifference * (10 ** 9)) /
                stake.priceInUsd;
            stake.amount += additionalGrlToReturn;
        }

        //calculate platform fee
        uint256 platformFee = calculateAdminFee(stake.amount);

        //calculate amount to return after deducting staking fee
        uint256 totalAmountToReturn = stake.amount - stakingFee - platformFee;
        // return  totalAmountToReturn;

        // Transfer Staking/Platform fee to amdin
        IERC20(grlTokenAddress).transfer(admin, stakingFee + platformFee);
        // Transfer GRL tokens back to the user
        IERC20(grlTokenAddress).transfer(msg.sender, totalAmountToReturn);

        hasUnstaked[msg.sender][index] = true;

        emit Unstaked(msg.sender, totalAmountToReturn);
    }

    function calculateStakingFee(
        uint256 durationInDays,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 feePercentage = 0;

        if (durationInDays >= 1 && durationInDays < 2) {
            feePercentage = stakingFeePercentage[30];
        } else if (durationInDays >= 2 && durationInDays < 3) {
            feePercentage = stakingFeePercentage[60];
        } else if (durationInDays >= 3 && durationInDays < 4) {
            feePercentage = stakingFeePercentage[90];
        } else if (durationInDays >= 4 && durationInDays < 5) {
            feePercentage = stakingFeePercentage[120];
        } else if (durationInDays >= 5 && durationInDays < 6) {
            feePercentage = stakingFeePercentage[150];
        } else if (durationInDays >= 6 && durationInDays < 7) {
            feePercentage = stakingFeePercentage[180];
        } else if (durationInDays >= 7 && durationInDays < 8) {
            feePercentage = stakingFeePercentage[210];
        } else if (durationInDays >= 8 && durationInDays < 9) {
            feePercentage = stakingFeePercentage[240];
        } else if (durationInDays >= 9 && durationInDays < 10) {
            feePercentage = stakingFeePercentage[270];
        } else if (durationInDays >= 10 && durationInDays < 11) {
            feePercentage = stakingFeePercentage[300];
        } else if (durationInDays >= 11 && durationInDays < 12) {
            feePercentage = stakingFeePercentage[330];
        } else if (durationInDays >= 12) {
            feePercentage = stakingFeePercentage[360];
        }

        require(feePercentage > 0, "Fee percentage not set for this duration");
        return (amount * feePercentage) / 10000000; // feePercentage is in basis points
    }

    function getUserStakeCount(address user) external view returns (uint256) {
        return userStakes[user].length;
    }

    function getUserStakeDetails(
        address user,
        uint256 index
    )
        external
        view
        returns (
            uint256 amount,
            uint256 timestamp,
            uint256 priceInUsd,
            uint256 amountInUsd
        )
    {
        require(index < userStakes[user].length, "Invalid index");
        Stake storage stake = userStakes[user][index];
        return (
            stake.amount,
            stake.stakingTime,
            stake.priceInUsd,
            stake.amountInUsd
        );
    }

    function withdrawGrl() external onlyAdmin {
        uint256 totalBalance = IERC20(grlTokenAddress).balanceOf(address(this));
        uint256 amountToWithdraw = totalBalance - totalStakedGrl;
        require(amountToWithdraw > 0, "Insufficient GRL");
        // Transfer GRL tokens to admin
        IERC20(grlTokenAddress).transfer(admin, amountToWithdraw);
        //emit GrlWithdrawn(admin, amount);
    }
}
