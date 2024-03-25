/**
 *Submitted for verification at Etherscan.io on 2024-02-29
 */

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

contract PriceGuaranteeStaking {
    address public admin;
    address public grlTokenAddress;
    address public wethAddress;
    address public uniswapRouterAddress;
    address public ethUsdAggregatorAddress;
    uint256 public constant DECIMALS = 18;

    uint256 public totalStakedGrl;

    mapping(uint256 => uint256) public stakingFeePercentage; // Mapping for staking fee percentage against duration in days

    struct Stake {
        uint256 durationInDays;
        uint256 amount;
        uint256 timestamp;
        uint256 priceInUsd; // Price of GRL in USD at the time of staking
        uint256 amountInUsd; // USD value of the staked amount
    }

    mapping(address => Stake[]) public userStakes;
    mapping(address => mapping(uint256 => bool)) public hasUnstaked;

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
        stakingFeePercentage[150] = 120000;
        stakingFeePercentage[180] = 138984;
        stakingFeePercentage[210] = 155475;
        stakingFeePercentage[240] = 169311;
        stakingFeePercentage[270] = 180611;
        stakingFeePercentage[300] = 189652;
        stakingFeePercentage[330] = 196771;
        stakingFeePercentage[360] = 202312;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
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

    function stakeGrl(uint256 amount, uint256 durationInDays) external {
        require(amount > 0, "Invalid amount");
        require(durationInDays % 30 == 0, "Invalid duration");

        uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
        uint256 stakingFee = calculateStakingFee(durationInDays, amount);
        uint256 amountToStake = amount - stakingFee;
        uint256 amountInUsd = (amountToStake * grlUsdPrice) / (10 ** 9);

        IERC20(grlTokenAddress).transferFrom(
            msg.sender,
            address(this),
            amountToStake
        );

        // Calculate timestamp for staking duration
        // uint256 stakingEndTime = block.timestamp + (durationInDays * 1 days);
        uint256 stakingEndTime = block.timestamp + (durationInDays * 10);
        // Record stake details
        userStakes[msg.sender].push(
            Stake({
                durationInDays: durationInDays,
                amount: amountToStake,
                timestamp: stakingEndTime,
                priceInUsd: grlUsdPrice,
                amountInUsd: amountInUsd
            })
        );

        // Transfer staking fee to admin
        // Assuming ERC20 transfer function exists
        IERC20(grlTokenAddress).transferFrom(msg.sender, admin, stakingFee);

        // Update total staked GRL
        totalStakedGrl += amountToStake;
        // Emit event
        emit Staked(
            msg.sender,
            amount,
            durationInDays,
            stakingEndTime,
            amountToStake,
            stakingFee,
            amountToStake
        );
    }

    function unstake(uint256 index) external {
        require(!hasUnstaked[msg.sender][index], "Stake already unstaked");
        Stake[] storage stakes = userStakes[msg.sender];
        require(index < stakes.length, "Invalid index");

        Stake storage stake = stakes[index];

        if (block.timestamp <= stake.timestamp) {
            // Staking duration has not passed yet
            uint256 totalAmountToReturn = stake.amount;
            uint256 grlUsdPrice = calculatePriceOfGrlInUsd();
            uint256 usdDifference = stake.priceInUsd - grlUsdPrice;

            if (usdDifference > 0) {
                // Calculate additional GRL to return
                uint256 additionalGrlToReturn = (usdDifference * (10 ** 9)) /
                    stake.priceInUsd;
                totalAmountToReturn += additionalGrlToReturn;
            }

            // Transfer GRL tokens back to the user
            // Assuming ERC20 transfer function exists
            IERC20(grlTokenAddress).transfer(msg.sender, totalAmountToReturn);
            hasUnstaked[msg.sender][index] = true;
            emit Unstaked(msg.sender, totalAmountToReturn);
        } else {
            // Transfer only staked amount back to the user
            IERC20(grlTokenAddress).transfer(msg.sender, stake.amount);
            hasUnstaked[msg.sender][index] = true;
            emit Unstaked(msg.sender, stake.amount);
        }

        // Update total staked GRL
        totalStakedGrl -= stake.amount;
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
            uint256 durationInDays,
            uint256 amount,
            uint256 timestamp,
            uint256 priceInUsd,
            uint256 amountInUsd
        )
    {
        require(index < userStakes[user].length, "Invalid index");
        Stake storage stake = userStakes[user][index];
        return (
            stake.durationInDays,
            stake.amount,
            stake.timestamp,
            stake.priceInUsd,
            stake.amountInUsd
        );
    }

    function calculateStakingFee(
        uint256 durationInDays,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 feePercentage = stakingFeePercentage[durationInDays];
        require(feePercentage > 0, "Fee percentage not set for this duration");
        return (amount * feePercentage) / 10000000; // feePercentage is in basis points
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

//Constructor Arguments

//// Testnet ////
//GRL: 0xb8a82D0A617C25Df80624Fb022eDEA9d2cF05171
//UniswapROuter: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//weth: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
//EACAggregatorProxy: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e

//// Mainnet ////
//GRL: 0xA067237f8016d5e3770CF08b20E343Ab9ee813d5
//UniswapRouter: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
//EACAggregatorProxy: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
