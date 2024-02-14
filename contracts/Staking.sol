// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GRLStaking {
    using SafeMath for uint256;

    IERC20 public immutable GRL;
    uint256 public rewardInterval; // Interval for updating reward per token stored
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    struct Staker {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lastInteraction;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => uint256) public rewardRates; // Mapping of staking duration to reward rate

    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);

    constructor(address _GRL) {
        GRL = IERC20(_GRL);
        rewardInterval =  1 days;
        lastUpdateTime = block.timestamp;
        rewardPerTokenStored =  0;

        // Initialize reward rates for different staking durations
        rewardRates[30 days] =  0.025  ether; //  0.025% daily return
        rewardRates[60 days] =  0.0275  ether; //  0.0275% daily return
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        rewardRates[60 days] =  0.0275  ether; 
        // ... Add other reward rates for different durations
    }

    modifier updateReward(address account, uint256 duration) {
        if (account != address(0)) {
            Staker storage staker = stakers[account];
            uint256 rewardRate = rewardRates[duration];
            uint256 pendingReward = staker.amount.mul(rewardPerTokenStored).div(1e18).sub(staker.rewardDebt);
            if (pendingReward >  0) {
                staker.rewardDebt = staker.amount.mul(rewardPerTokenStored).div(1e18);
                staker.lastInteraction = block.timestamp;

                
                GRL.transfer(account, pendingReward);
                emit Claimed(account, pendingReward);
            }
        }
        _;
    }

    function stake(uint256 amount, uint256 duration) public updateReward(msg.sender, duration) {
        require(amount >  0, "Cannot stake  0");
        GRL.transferFrom(msg.sender, address(this), amount);
        Staker storage staker = stakers[msg.sender];
        staker.amount = staker.amount.add(amount);
        staker.rewardDebt = staker.amount.mul(rewardPerTokenStored).div(1e18);
        emit Staked(msg.sender, amount, duration);
    }

    function unstake(uint256 amount) public updateReward(msg.sender,  0) {
        require(amount <= stakers[msg.sender].amount, "Not enough staked");
        Staker storage staker = stakers[msg.sender];
        staker.amount = staker.amount.sub(amount);
        staker.rewardDebt = staker.amount.mul(rewardPerTokenStored).div(1e18);
        GRL.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claim() public updateReward(msg.sender,  0) {
        // No need to do anything here since the reward is transferred during updateReward
    }

    function updateRewardPerToken() public {
        if (block.timestamp > lastUpdateTime) {
            uint256 elapsedTime = block.timestamp.sub(lastUpdateTime);
            uint256 totalReward = elapsedTime.mul(rewardPerTokenStored).div(10000); // Convert bps to %
            rewardPerTokenStored = rewardPerTokenStored.add(totalReward.mul(1e18).div(totalStaked()));
            lastUpdateTime = block.timestamp;
        }
    }

    function totalStaked() public view returns (uint256) {
        uint256 totalStaked =  0;
        for (address staker : stakers) {
            totalStaked = totalStaked.add(stakers[staker].amount);
        }
        return totalStaked;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        if (from != address(0)) {
            updateReward(from,  0);
        }
        if (to != address(0)) {
            updateReward(to,  0);
        }
    }
}
