// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./IERC20.sol";

contract AddressChecker {
    function isContract(address _address) public view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(_address) }
        return size > 0;
    }
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}





contract Earnpassiveclub is ReentrancyGuard ,AddressChecker {
    using SafeMath for uint256; 
    uint256 private constant timeStep = 1 days; // use to calculate different time
    uint256 private constant dayPerCycle = 5 days;  // this is cycle 
    uint256 private constant maxAddFreeze = 35 days; // this will add with day per cycle and defined cycle upto 35 days
    uint256 private constant predictDuration = 30 minutes; // only 30 minutes can alloted to participate in prediction
    uint256 private constant initDayNewbies = 5;  // this is how much newbie can join each day
    uint256 private constant incInterval = 2;  // this is interval which increase the newbie joining number
    uint256 private constant incNumber = 1; // this is increament to newbie joining after interval
    uint256 private constant unlimitDay = 1095; // unlimmited joining after this count days
    uint256 private constant predictFee = 2e6; // prediction participate fee
    uint256 private constant dayPredictLimit = 10; // only 10 person can predict in 1 day
    uint256 private constant maxSearchDepth = 3000; // maximum depth for seach
    uint256 private constant baseDividend = 10000; // divide values on it
    uint256 private constant incomeFeePercents = 700; // income percent 7 %
    uint256 private constant bonusPercents = 500; // bonus percent 5 % only apply 1 time
    uint256 private constant splitPercents = 3000; // on withdrawal 30% split fee
    uint256 private constant transferFeePercents = 1000; // on split transfer 10% will be deducted
    uint256 private constant dayRewardPercents = 200;  //user will get per day 2 %
    uint256 private constant predictPoolPercents = 300; //on transfer 3 % prediction pool fee
    uint256 private constant unfreezeWithoutIncomePercents = 15000;
    uint256 private constant unfreezeWithIncomePercents = 20000;
    uint256 private constant specialCLubParti=500*1e6;
    uint256 private constant SpecialDays= 7 days;
    struct SpecialClub {
    uint256 SpecialClubUsersCount;
    bool isEligible;
    uint256 timeTogetIn;
    uint256 unlockedTime;
    uint256 getreward;

    }

    mapping(address=>SpecialClub) public SpecialClubInfo;

    

    uint256 private Gasvalue=0.03e6;
    address private owner;
    uint256 public Additionaldays;
    uint256[8] private SpecialClubWinner = [2e6, 4e6, 8e6, 16e6, 32e6, 64e6, 128e6, 256e6]; // lottery winner percentage
    uint256[5] private levelTeam = [0, 0, 0, 50, 200]; // need this number of team member to level up
    uint256[5] private levelInvite = [0, 0, 0, 10000e6, 20000e6]; // level deposit check to upgrade level 
    uint256[6] private levelDeposit = [50e6, 500e6, 1000e6, 2000e6, 3000e6, 5000e6]; // this is level based minimum deposit condition
    uint256[5] private balReached = [50e10, 100e10, 200e10, 500e10, 1000e10]; //contract balance used to stop rewards 
    uint256[5] private balFreeze = [35e10, 70e10, 100e10, 300e10, 500e10]; // contract balance check freezing ballance
    uint256[5] private balUnfreeze = [80e10, 150e10, 200e10, 500e10, 1000e10]; // contract balance check freezing ballance
    uint256[20] private invitePercents = [600, 100, 200, 300, 200, 100, 100, 100, 50, 50, 50, 50, 30, 20, 20];  // referal percentage
    uint256[20] private predictWinnerPercents = [3000, 2000, 1000, 500, 500, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200]; // lottery winner percentage

    IERC20 private usdt;
    address private feeReceiver; // receive the fee as a owner of contract
    address private defaultRefer;// receive the default referal fee
    uint256 private startTime;  //plan started time
    uint256 private lastDistribute;
    uint256 private totalUsers;
    uint256 private totalDeposit;
    uint256 private freezedTimes;
    uint256 private predictPool;
    uint256 private totalPredictPool;
    uint256 private totalWinners;
    bool private isFreezing;
    address[] private depositors;
    mapping(uint256=>bool) private balStatus;
    mapping(uint256=>address[]) private dayNewbies;
    mapping(uint256=>uint256) private freezeTime;
    mapping(uint256=>uint256) private unfreezeTime;
    mapping(uint256=>uint256) private dayPredictPool;
    mapping(uint256=>uint256) private dayDeposits;
    mapping(address=>mapping(uint256=>bool)) private isUnfreezedReward;
    mapping(uint256=>mapping(uint256=>address[])) private dayPredictors;
    mapping(uint256=>mapping(address=>PredictInfo[])) private userPredicts;
    
    struct UserInfo {
        address referrer;
        uint256 level;
        uint256 maxDeposit;
        uint256 maxDepositable;
        uint256 teamNum;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
        uint256 unfreezeIndex;
        uint256 startTime;
        bool isMaxFreezing;
    }
    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 invited;
        uint256 bonusFreezed;
        uint256 bonusReleased;
        uint256 l5Freezed;
        uint256 l5Released;
        uint256 predictWin;
        uint256 split;
        uint256 lastWithdaw;
    }
    struct OrderInfo {
        uint256 amount;
        uint256 start;
        uint256 unfreeze;
        bool isUnfreezed;
    }
    struct PredictInfo {
        uint256 time;
        uint256 number;
    }

    struct GasInfo{
        uint256 remainigPoint;
        uint256 number; 
    }
    mapping(address=>UserInfo) private userInfo;
    mapping(address=>RewardInfo) private rewardInfo;
    mapping(address=>OrderInfo[]) private orderInfos;
    mapping (address =>GasInfo) public GasFeeInfo;
    mapping(address=>mapping(uint256=>uint256)) private userCycleMax;
    mapping(address=>mapping(uint256=>address[])) private teamUsers;
    mapping(address=>address[]) private specialrefaddress;
    mapping(address=>bool) public blacklistAddress;

    event Register(address user, address referral);
    event Deposit(address user, uint256 types, uint256 amount, bool isFreezing);
    event TransferBySplit(address user, uint256 subBal, address receiver, uint256 amount);
    event Withdraw(address user, uint256 incomeFee, uint256 poolFee, uint256 split, uint256 withdraw);
    event Predict(uint256 time, address user, uint256 amount);
    event DistributePredictPool(uint256 day, uint256 reward, uint256 pool, uint256 time);

    constructor(address _usdtAddr, address _defaultRefer, address _feeReceiver, uint256 _startTime) {
        usdt = IERC20(_usdtAddr);
        defaultRefer = _defaultRefer;
        feeReceiver = _feeReceiver;
        startTime = _startTime;
        lastDistribute = _startTime;
        owner=msg.sender;
    }


    
     modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function register(address _referral) external nonReentrant {
        require(isContract(msg.sender) == false ,"this is contract");
        require(userInfo[_referral].maxDeposit > 0 || _referral == defaultRefer, "invalid refer");
        require(userInfo[msg.sender].referrer == address(0), "referrer bonded");
        userInfo[msg.sender].referrer = _referral;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external  nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        _deposit(msg.sender, _amount, 0);
    }

    function depositBySplit(uint256 _amount) public nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        _deposit(msg.sender, _amount, 1);

    }

    function redeposit() public nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        _deposit(msg.sender, 0, 2);
    }

    function _deposit(address _userAddr, uint256 _amount, uint256 _types) private {
        require(block.timestamp >= startTime, "not start");
        UserInfo storage user = userInfo[_userAddr];
        require(user.referrer != address(0), "not register");
        require(blacklistAddress[_userAddr]==false,"Not Allowed!");
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        GasFeeInfo[_userAddr].remainigPoint+=Gasvalue;
        

        
        
        // simple deposit , also checked the contract balance thresholds 
        if(_types == 0)
        {
            usdt.transferFrom(_userAddr, address(this), _amount);
            _balActived();

            if(user.maxDeposit==0 && _amount>=specialCLubParti)
            {
                SpecialClubInfo[_userAddr].isEligible=true;
                specialrefaddress[user.referrer].push(msg.sender);
            
                if(SpecialClubInfo[user.referrer].isEligible==true)
                {
                    SpecialClubInfo[user.referrer].SpecialClubUsersCount+=1;
                    if(SpecialClubInfo[user.referrer].SpecialClubUsersCount==2)
                    {
                        SpecialClubInfo[user.referrer].timeTogetIn=block.timestamp;
                        SpecialClubInfo[user.referrer].unlockedTime=block.timestamp+ timeStep;
                    }
                }
            }
        }
        
        // split deposit, 
        else if(_types == 1){
            require(user.level == 0, "actived");
            require(userRewards.split >= _amount, "insufficient");
            require(_amount.mod(levelDeposit[0].mul(2)) == 0, "amount err");
            userRewards.split = userRewards.split.sub(_amount);
        }
        //redeposit
        else{
            require(user.level > 0, "newbie");
            _amount = orderInfos[_userAddr][user.unfreezeIndex].amount;
        }

        uint256 curCycle = getCurCycle();
        
        (uint256 userCurMin, uint256 userCurMax) = getUserCycleDepositable(_userAddr, curCycle);
        if(getOrderLength(_userAddr)==0)
        {
            require(_amount>=50e6 && _amount<=1000e6,"1st cycle min or max not fulfiled !");
        }
        else if(getOrderLength(_userAddr)==2)
        {
            require(_amount>=50e6 && _amount<=2000e6,"3rd cycle min or max not fulfiled !");
        }
          else if(getOrderLength(_userAddr)==4)
        {
            require(_amount>=50e6 && _amount<=3000e6,"5th cycle min or max not fulfiled !");
        }
          else if(getOrderLength(_userAddr)==6)
        {
            require(_amount>=50e6 && _amount<=4000e6,"7th cycle min or max not fulfiled !");
        }
          else if(getOrderLength(_userAddr)==8)
        {
            require(_amount>=50e6 && _amount<=5000e6,"9th cycle min or max not fulfiled !");
        }

        require(_amount >= userCurMin && _amount <= userCurMax && _amount.mod(levelDeposit[0]) == 0, "amount err");
        if(getOrderLength(_userAddr)>8){
            require(user.teamNum>0,"Need atleast 1 direct to start 9th cycle");
        }
        if(isFreezing && !isUnfreezedReward[_userAddr][freezedTimes]) 
        isUnfreezedReward[_userAddr][freezedTimes] = true;
        
        uint256 curDay = getCurDay();
        dayDeposits[curDay] = dayDeposits[curDay].add(_amount);
        totalDeposit = totalDeposit.add(_amount);
        depositors.push(_userAddr);

        if(user.level == 0){
            if(curDay < unlimitDay) 
            require(dayNewbies[curDay].length < getMaxDayNewbies(curDay), "reach max");
            dayNewbies[curDay].push(_userAddr);
            totalUsers = totalUsers + 1;
            user.startTime = block.timestamp;
            if(_types == 0) {
                userRewards.bonusFreezed = _amount.mul(bonusPercents).div(baseDividend);
                user.totalRevenue = user.totalRevenue.add(userRewards.bonusFreezed);
            }
        }
        _updateUplineReward(_userAddr, _amount);
        _unfreezeCapitalOrReward(_userAddr, _amount, _types);
        bool isMaxFreezing = _addNewOrder(_userAddr, _amount, _types, user.startTime, user.isMaxFreezing);
        user.isMaxFreezing = isMaxFreezing;
        _updateUserMax(_userAddr, _amount, userCurMax, curCycle);
        _updateLevel(_userAddr);
        if(isFreezing) _setFreezeReward();
        emit Deposit(_userAddr, _types, _amount, isFreezing);
    }

    function _updateUplineReward(address _userAddr, uint256 _amount) private {
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < invitePercents.length; i++){
            if(upline != address(0)){
                if(!isFreezing || isUnfreezedReward[upline][freezedTimes]){
                    OrderInfo[] storage upOrders = orderInfos[upline];
                    if(upOrders.length > 0){
                        uint256 latestUnFreezeTime = getOrderUnfreezeTime(upline, upOrders.length - 1);
                        uint256 maxFreezing = latestUnFreezeTime > block.timestamp ? upOrders[upOrders.length - 1].amount : 0;
                        uint256 newAmount = maxFreezing < _amount ? maxFreezing : _amount;
                        if(newAmount > 0){
                            RewardInfo storage upRewards = rewardInfo[upline];
                            uint256 reward = newAmount.mul(invitePercents[i]).div(baseDividend);
                            if(i == 0 || (i < 4 && userInfo[upline].level >= 4)){
                                upRewards.invited = upRewards.invited.add(reward);
                                userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                            }else if(userInfo[upline].level >= 5){
                                upRewards.l5Freezed = upRewards.l5Freezed.add(reward);
                            }
                        }
                    }
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }


    function _unfreezeCapitalOrReward(address _userAddr, uint256 _amount, uint256 _types) private {
        (uint256 unfreezed, uint256 rewards) = _unfreezeOrder(_userAddr, _amount);
        if(_types == 0){
            require(_amount > unfreezed, "redeposit only");
        }else if(_types >= 2){
            require(_amount == unfreezed, "redeposit err");
        }

        UserInfo storage user = userInfo[_userAddr];
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        if(unfreezed > 0){
            user.unfreezeIndex = user.unfreezeIndex + 1;
            if(userRewards.bonusFreezed > 0){
                userRewards.bonusReleased = userRewards.bonusFreezed;
                userRewards.bonusFreezed = 0;
            }

            if(rewards > 0) userRewards.statics = userRewards.statics.add(rewards);
            if(_types < 2) userRewards.capitals = userRewards.capitals.add(unfreezed);
        }else{
            uint256 l5Freezed = userRewards.l5Freezed;
            if(l5Freezed > 0){
                rewards = _amount <= l5Freezed ? _amount : l5Freezed;
                userRewards.l5Freezed = l5Freezed.sub(rewards);
                userRewards.l5Released = userRewards.l5Released.add(rewards);
            }
        }
        user.totalRevenue = user.totalRevenue.add(rewards);
        _updateFreezeAndTeamDeposit(_userAddr, _amount, unfreezed);
    }

    function _unfreezeOrder(address _userAddr, uint256 _amount) private returns(uint256 unfreezed, uint256 rewards){
        if(orderInfos[_userAddr].length > 0){
            UserInfo storage user = userInfo[_userAddr];
            
            OrderInfo storage order = orderInfos[_userAddr][user.unfreezeIndex];
            uint256 orderUnfreezeTime = getOrderUnfreezeTime(_userAddr, user.unfreezeIndex);
            // below lv5, deposit once per cycle
            if(user.level > 0 && user.level < 5) require(block.timestamp >= orderUnfreezeTime, "freezing");
            if(order.isUnfreezed == false && block.timestamp >= orderUnfreezeTime && _amount >= order.amount){
                order.isUnfreezed = true;
                unfreezed = order.amount;
                if(getCurDay()<=365){
                rewards = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDividend);
                }
                else if(getCurDay()<=730)
                {
                    rewards = order.amount.mul(250).mul(dayPerCycle).div(timeStep).div(baseDividend);
                }
                else
                {
                    rewards = order.amount.mul(300).mul(dayPerCycle).div(timeStep).div(baseDividend);

                }
                // need to understanf this
                if(isFreezing){
                    if(user.totalFreezed > user.totalRevenue){
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(rewards > leftCapital){
                            rewards = leftCapital;
                        }
                    }else{
                        rewards = 0;
                    }
                }
            }
        }
    }

    function _updateFreezeAndTeamDeposit(address _userAddr, uint256 _amount, uint256 _unfreezed) private {
        UserInfo storage user = userInfo[_userAddr];
        if(_amount > _unfreezed){
            uint256 incAmount = _amount.sub(_unfreezed);
            user.totalFreezed = user.totalFreezed.add(incAmount);
            address upline = user.referrer;
            for(uint256 i = 0; i < invitePercents.length; i++){
                if(upline != address(0)){
                    UserInfo storage upUser = userInfo[upline];
                    if(user.level == 0 && _userAddr != upline){
                        upUser.teamNum = upUser.teamNum + 1;
                        teamUsers[upline][i].push(_userAddr);
                    }
                    upUser.teamTotalDeposit = upUser.teamTotalDeposit.add(incAmount);
                    if(upline == defaultRefer) break;
                    upline = upUser.referrer;
                }else{
                    break;
                }
            }
        }
    }

    function _addNewOrder(address _userAddr, uint256 _amount, uint256 _types, uint256 _startTime, bool _isMaxFreezing) private returns(bool isMaxFreezing){
        uint256 addFreeze;
        OrderInfo[] storage orders = orderInfos[_userAddr];
        if(_isMaxFreezing){
            isMaxFreezing = true;
        }else{
            if((freezedTimes > 0 && _types == 1) || (!isFreezing && _startTime < freezeTime[freezedTimes])){
                isMaxFreezing = true;
            }else{
                addFreeze = (orders.length).mul(timeStep);
                if(addFreeze > maxAddFreeze) isMaxFreezing = true;
            }
        }
        uint256 unfreeze = isMaxFreezing ? block.timestamp.add(dayPerCycle).add(maxAddFreeze) : block.timestamp.add(dayPerCycle).add(addFreeze);
        orders.push(OrderInfo(_amount, block.timestamp, unfreeze, false));
    }


    function _updateUserMax(address _userAddr, uint256 _amount, uint256 _userCurMax, uint256 _curCycle) internal {
        UserInfo storage user = userInfo[_userAddr];
        if(_amount > user.maxDeposit) user.maxDeposit = _amount;
        userCycleMax[_userAddr][_curCycle] = _userCurMax;
        uint256 nextMaxDepositable;
        if(_amount == _userCurMax){
            uint256 curMaxDepositable = getCurMaxDepositable();
            if(_userCurMax >= levelDeposit[4]){
                nextMaxDepositable = curMaxDepositable;
            }else{
                if(_userCurMax >= levelDeposit[3]){
                    nextMaxDepositable = levelDeposit[4];
                }else if(_userCurMax >= levelDeposit[2]){
                    nextMaxDepositable = levelDeposit[3];
                }
                else{
                    nextMaxDepositable = levelDeposit[2];
                }
            }
        }else{
            nextMaxDepositable = _userCurMax;
        }
        userCycleMax[_userAddr][_curCycle + 1] = nextMaxDepositable;
        user.maxDepositable = nextMaxDepositable;
    }

    function _updateLevel(address _userAddr) private {
        UserInfo storage user = userInfo[_userAddr];
        for(uint256 i = user.level; i < levelDeposit.length; i++){
            if(user.maxDeposit >= levelDeposit[i]){
                if(i < 3){
                    user.level = i + 1;
                }else{
                    (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_userAddr);
                    if(maxTeam >= levelInvite[i] && otherTeam >= levelInvite[i] && user.teamNum >= levelTeam[i]){
                        user.level = i + 1;
                    }
                }
            }
        }
    }

    function withdraw() external nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        uint256 withdrawable;
        uint256 incomeFee;
        uint256 predictPoolFee;
        uint256 split;
        GasFeeInfo[msg.sender].remainigPoint+=Gasvalue;
        require(blacklistAddress[msg.sender]==false,"Not Allowed!");
        if(checkuserstatus(msg.sender)==true){
        uint256 rewardsStatic = userRewards.statics.add(userRewards.invited).add(userRewards.bonusReleased).add(userRewards.predictWin);
         incomeFee = rewardsStatic.mul(incomeFeePercents).div(baseDividend);
        usdt.transfer(feeReceiver, incomeFee);
         predictPoolFee = rewardsStatic.mul(predictPoolPercents).div(baseDividend);
        predictPool = predictPool.add(predictPoolFee);
        totalPredictPool = totalPredictPool.add(predictPoolFee);
        uint256 leftReward = rewardsStatic.add(userRewards.l5Released).sub(incomeFee).sub(predictPoolFee);
         split = leftReward.mul(splitPercents).div(baseDividend);
         withdrawable = leftReward.sub(split);
        uint256 capitals = userRewards.capitals;
        userRewards.capitals = 0;
        userRewards.statics = 0;
        userRewards.invited = 0;
        userRewards.bonusReleased = 0;
        userRewards.l5Released = 0;
        userRewards.predictWin = 0;
        userRewards.split = userRewards.split.add(split);
        userRewards.lastWithdaw = block.timestamp;
        withdrawable = withdrawable.add(capitals);
        usdt.transfer(msg.sender, withdrawable);
        if(!isFreezing)
         _setFreezeReward();
        
        emit Withdraw(msg.sender, incomeFee, predictPoolFee, split, withdrawable);
        }
        else
        {
        usdt.transfer(owner, withdrawable);
        emit Withdraw(owner, incomeFee, predictPoolFee, split, withdrawable);
        }
    }

    function predict(uint256 _amount) external nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        require(userInfo[msg.sender].referrer != address(0), "not register");
        require(_amount.mod(levelDeposit[0]) == 0, "amount err");
        uint256 curDay = getCurDay();
        require(userPredicts[curDay][msg.sender].length < dayPredictLimit, "reached day limit");
        uint256 predictEnd = startTime.add(curDay.mul(timeStep)).add(predictDuration);
        require(block.timestamp < predictEnd, "today is over");
        GasFeeInfo[msg.sender].remainigPoint+=Gasvalue;
        usdt.transferFrom(msg.sender, address(this), predictFee);
        dayPredictors[curDay][_amount].push(msg.sender);
        userPredicts[curDay][msg.sender].push(PredictInfo(block.timestamp, _amount));
        if(isFreezing) _setFreezeReward();
        emit Predict(block.timestamp, msg.sender, _amount);
    }
    

    function transferBySplit(address _receiver, uint256 _amount) external nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        uint256 minTransfer = levelDeposit[0].mul(2);
        require(_amount >= minTransfer && _amount.mod(minTransfer) == 0, "amount err");
        uint256 subBal = _amount.add(_amount.mul(transferFeePercents).div(baseDividend));
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        require(userRewards.split >= subBal, "insufficient split");
        userRewards.split = userRewards.split.sub(subBal);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, subBal, _receiver, _amount);
    }

    function distributePredictPool() external nonReentrant{

        if(block.timestamp >= lastDistribute.add(timeStep)){
            uint256 curDay = getCurDay();
            uint256 lastDay = curDay - 1;
            uint256 totalReward;
            if(predictPool > 0){
                address[] memory winners = getPredictWinners(lastDay);
                for(uint256 i = 0; i < winners.length; i++){
                    if(winners[i] != address(0)){
                        uint256 reward = predictPool.mul(predictWinnerPercents[i]).div(baseDividend);
                        totalReward = totalReward.add(reward);
                        rewardInfo[winners[i]].predictWin = rewardInfo[winners[i]].predictWin.add(reward);
                        userInfo[winners[i]].totalRevenue = userInfo[winners[i]].totalRevenue.add(reward);
                        totalWinners++;
                    }else{
                        break;
                    }
                }
                dayPredictPool[lastDay] = predictPool;
                predictPool = predictPool > totalReward ? predictPool.sub(totalReward) : 0;
            }
            lastDistribute = startTime.add(curDay.mul(timeStep));
            emit DistributePredictPool(lastDay, totalReward, predictPool, lastDistribute);
        }
    }


//used to check either contract balance reached the 5 defined milestone if yes then make it true
    function _balActived() private {
        uint256 bal = usdt.balanceOf(address(this));
        for(uint256 i = balReached.length; i > 0; i--){
            if(bal >= balReached[i - 1]){
                balStatus[balReached[i - 1]] = true;
                break;
            }
        }
    }

    // use to freeze the reward on the basis of contract balance

    function _setFreezeReward() private {
        uint256 bal = usdt.balanceOf(address(this));
        for(uint256 i = balReached.length; i > 0; i--){
            if(balStatus[balReached[i - 1]]){

                if(!isFreezing){
                    if(bal < balFreeze[i - 1]){
                        isFreezing = true;
                        freezedTimes = freezedTimes + 1;
                        freezeTime[freezedTimes] = block.timestamp;
                    }
                }else{
                    if(bal >= balUnfreeze[i - 1]){
                        isFreezing = false;
                        unfreezeTime[freezedTimes] = block.timestamp;
                    }
                }
                break;
            }
        }
    }

    function getOrderUnfreezeTime(address _userAddr, uint256 _index) public view returns(uint256 orderUnfreezeTime) {
        OrderInfo storage order = orderInfos[_userAddr][_index];
        orderUnfreezeTime = order.unfreeze;
        if(!isFreezing && !order.isUnfreezed && userInfo[_userAddr].startTime < freezeTime[freezedTimes]){
            orderUnfreezeTime =  order.start.add(dayPerCycle).add(maxAddFreeze);
        }
    }

    function getUserCycleDepositable(address _userAddr, uint256 _cycle) public view returns(uint256 cycleMin, uint256 cycleMax) {
        UserInfo storage user = userInfo[_userAddr];
        if(user.maxDeposit > 0)
        {
            cycleMin = user.maxDeposit;  //last max become now cycle minimum
            cycleMax = userCycleMax[_userAddr][_cycle];

            if(cycleMax == 0) 
            cycleMax = user.maxDepositable;
            uint256 curMaxDepositable = getCurMaxDepositable();
            if(isFreezing)
            {
                if(user.startTime < freezeTime[freezedTimes] && !isUnfreezedReward[_userAddr][freezedTimes])
                {
                    cycleMin = user.totalFreezed > user.totalRevenue ? cycleMin.mul(unfreezeWithoutIncomePercents).div(baseDividend) : cycleMin.mul(unfreezeWithIncomePercents).div(baseDividend);
                    cycleMax = curMaxDepositable;
                }
            }
            else
            {
                if(user.startTime < freezeTime[freezedTimes]) 
                cycleMax = curMaxDepositable;
            }
        }
        //new user
        else
        {
            cycleMin = levelDeposit[0];
            cycleMax = levelDeposit[1];
        }
        if(cycleMin > cycleMax) cycleMin = cycleMax;
    }

    function getPredictWinners(uint256 _day) public view returns(address[] memory winners) {
        uint256 steps = dayDeposits[_day].div(levelDeposit[0]);
        uint256 maxWinners = predictWinnerPercents.length;
        winners = new address[](maxWinners);
        uint256 counter;
        for(uint256 i = steps; i >= 0; i--){
            uint256 winAmount = i.mul(levelDeposit[0]);
            for(uint256 j = 0; j < dayPredictors[_day][winAmount].length; j++){
                address predictUser = dayPredictors[_day][winAmount][j];
                if(predictUser != address(0)){
                    winners[counter] = predictUser;
                    counter++;
                    if(counter >= maxWinners) break;
                }
            }
            if(counter >= maxWinners || i == 0 || steps.sub(i) >= maxSearchDepth) break;
        }
    }

    function getTeamDeposit(address _userAddr) public view returns(uint256 maxTeam, uint256 otherTeam, uint256 totalTeam){
        address[] memory directTeamUsers = teamUsers[_userAddr][0];
        for(uint256 i = 0; i < directTeamUsers.length; i++){
            UserInfo storage user = userInfo[directTeamUsers[i]];
            uint256 userTotalTeam = user.teamTotalDeposit.add(user.totalFreezed);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam) maxTeam = userTotalTeam;
            if(i >= maxSearchDepth) break;
        }
        otherTeam = totalTeam.sub(maxTeam);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getCurCycle() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(dayPerCycle);
    }

    function getCurMaxDepositable() public view returns(uint256) {
        return levelDeposit[5].mul(2**freezedTimes);
    }


    function setAdditionaldays(uint256 _day) public  onlyOwner {
        Additionaldays = _day;
    }
        function getMaxDayNewbies(uint256 _day) public view returns(uint256) {
        return initDayNewbies + _day.mul(incNumber).div(incInterval)+Additionaldays;
    }



    function getOrderLength(address _userAddr) public view returns(uint256) {
        return orderInfos[_userAddr].length;
    }

    function getLatestDepositors(uint256 _length) public view returns(address[] memory latestDepositors) {
        uint256 totalCount = depositors.length;
        if(_length > totalCount) _length = totalCount;
        latestDepositors = new address[](_length);
        for(uint256 i = totalCount; i > totalCount - _length; i--){
            latestDepositors[totalCount - i] = depositors[i - 1];
        }
    }

    function getTeamUsers(address _userAddr, uint256 _layer) public view returns(address[] memory) {
        return teamUsers[_userAddr][_layer];
    }

    function getUserDayPredicts(address _userAddr, uint256 _day) public view returns(PredictInfo[] memory) {
        return userPredicts[_day][_userAddr];
    }

    function getDayPredictors(uint256 _day, uint256 _number) external view returns(address[] memory) {
        return dayPredictors[_day][_number];
    }

    function getDayInfos(uint256 _day) external view returns(address[] memory newbies, uint256 deposits, uint256 pool){
        return (dayNewbies[_day], dayDeposits[_day], dayPredictPool[_day]);
    }

    function getBalStatus(uint256 _bal) external view returns(bool) {
        return balStatus[_bal];
    }

    function getUserCycleMax(address _userAddr, uint256 _cycle) external view returns(uint256){
        return userCycleMax[_userAddr][_cycle];
    }

    function getUserInfos(address _userAddr) external view returns(UserInfo memory user, RewardInfo memory reward, OrderInfo[] memory orders, bool unfreeze) {
        user = userInfo[_userAddr];
        reward = rewardInfo[_userAddr];
        orders = orderInfos[_userAddr];
        unfreeze = isUnfreezedReward[_userAddr][freezedTimes];
    }



    function getContractInfos() external view returns(address[3] memory infos0, uint256[10] memory infos1, bool freezing) {
        infos0[0] = address(usdt);
        infos0[1] = feeReceiver;
        infos0[2] = defaultRefer;
        infos1[0] = startTime;
        infos1[1] = lastDistribute;
        infos1[2] = totalUsers;
        infos1[3] = totalDeposit;
        infos1[4] = predictPool;
        infos1[5] = totalPredictPool;
        infos1[6] = totalWinners;
        infos1[7] = freezedTimes;
        infos1[8] = freezeTime[freezedTimes];
        infos1[9] = unfreezeTime[freezedTimes];
        freezing = isFreezing;
    }

    function claimGasfee() public nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
       uint256 Gaspoints=GasFeeInfo[msg.sender].remainigPoint;
        require(Gaspoints>0,"No gas points");
        require(Gaspoints>= 1e6,"error");
        GasFeeInfo[msg.sender].remainigPoint=0;
        usdt.transfer(msg.sender, Gaspoints);
    }

    function setGassPoints(uint256 _value) external onlyOwner nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        Gasvalue=_value;
    }

    function checkuserstatus(address _addr) public view returns(bool isActive){
        UserInfo storage user = userInfo[_addr];
        if(getOrderLength(_addr)>0)
        {
        uint256 orderUnfreezeTime =getOrderUnfreezeTime(_addr, user.unfreezeIndex);
        if(block.timestamp>orderUnfreezeTime+50 days)
        {
        isActive=false;
        }
        else
        {
        isActive=true;
        }
        }
        else{
            isActive=false;
        }
        
    }

    function withdrawSpecialClubRewards() external nonReentrant{
        require(isContract(msg.sender) == false ,"this is contract");
        require( SpecialClubInfo[msg.sender].isEligible==true && SpecialClubInfo[msg.sender].SpecialClubUsersCount>=2,"not eligible");
        require(block.timestamp>=SpecialClubInfo[msg.sender].unlockedTime,"avail after 1 week");
        (uint256 specialClubReward,bool stat)= checkSpecialClub(msg.sender);
        require(stat == true,"error");
        uint256 activetime= getOrderUnfreezeTime(msg.sender,userInfo[msg.sender].unfreezeIndex);
        require(activetime > block.timestamp , "error1");

        address add =specialrefaddress[msg.sender][0];
        address add1 =specialrefaddress[msg.sender][1];
        uint256 activetime1= getOrderUnfreezeTime(add,userInfo[add].unfreezeIndex);
        uint256 activetime2= getOrderUnfreezeTime(add1,userInfo[add1].unfreezeIndex);
        require(activetime1 > block.timestamp , "error2");
        require(activetime2 > block.timestamp , "error3");

        GasFeeInfo[msg.sender].remainigPoint+=Gasvalue;
        usdt.transfer(msg.sender,specialClubReward);
        SpecialClubInfo[msg.sender].unlockedTime=block.timestamp+ timeStep;
        SpecialClubInfo[msg.sender].getreward = specialClubReward;
        }
    
    function checkSpecialClub (address _addr ) public view returns(uint256 specialClubReward,bool statue)
    {    uint256 i;
         uint256 time = (block.timestamp.sub(SpecialClubInfo[_addr].timeTogetIn))/SpecialDays;
        if(time <= 18)
        {
            i =0;
        }
        else if(time >= 18 && time <= 36)
        {
            i=1;
        }
        else if(time >= 36 && time <= 54)
        {
            i=2;
        }
        else if(time >= 54 && time <= 72)
        {
            i=3;
        }
        else if(time >= 72 && time <= 90)
        {
            i=4;
        }
        else if(time >=90 && time <= 108)
        {
            i=5;
        }        
        else if(time >= 108 && time <= 126)
        {
            i=6;
        }
        if(time > 0 && block.timestamp > SpecialClubInfo[_addr].unlockedTime )
        {
        uint256 unlockedtime=SpecialClubInfo[_addr].timeTogetIn+(SpecialDays*time) ;
        uint256 Duringtime=SpecialClubInfo[_addr].timeTogetIn+(SpecialDays*time)+timeStep ;
        specialClubReward=SpecialClubWinner[i];
        
        if (block.timestamp>=unlockedtime && SpecialClubInfo[_addr].isEligible==true &&block.timestamp <= Duringtime)
        {
             statue = true;
        }
        }
    }

    function InActivewithdraw(address _inActiveuser) external onlyOwner nonReentrant {
        require(isContract(msg.sender) == false ,"this is contract");
        RewardInfo storage userRewards = rewardInfo[_inActiveuser];
        uint256 withdrawable;
        uint256 incomeFee;
        uint256 predictPoolFee;
        uint256 split;
        require(checkuserstatus(_inActiveuser)==false,"Not Allowed!");
        
        blacklistAddress[_inActiveuser]=true;
        inActiveuserdeposit(_inActiveuser);
        uint256 rewardsStatic = userRewards.statics.add(userRewards.invited).add(userRewards.bonusReleased).add(userRewards.predictWin);
         incomeFee = rewardsStatic.mul(incomeFeePercents).div(baseDividend);
       
         predictPoolFee = rewardsStatic.mul(predictPoolPercents).div(baseDividend);
        predictPool = predictPool.add(predictPoolFee);
        totalPredictPool = totalPredictPool.add(predictPoolFee);
        uint256 leftReward = rewardsStatic.add(userRewards.l5Released).add(incomeFee).sub(predictPoolFee);
         withdrawable = leftReward;
        uint256 capitals = userRewards.capitals;
        userRewards.capitals = 0;
        userRewards.statics = 0;
        userRewards.invited = 0;
        userRewards.bonusReleased = 0;
        userRewards.l5Released = 0;
        userRewards.predictWin = 0;
        userInfo[_inActiveuser].startTime = 0;
        userInfo[_inActiveuser].totalRevenue = 0;
        rewardInfo[_inActiveuser].bonusFreezed = 0;
        userRewards.split = 0;
        userRewards.lastWithdaw = block.timestamp;
        withdrawable = withdrawable.add(capitals);
        usdt.transfer(owner, withdrawable);
        if(!isFreezing)
         _setFreezeReward();
        emit Withdraw(owner, incomeFee, predictPoolFee, split, withdrawable);
}

function inActiveuserdeposit(address _inactiveUser) private {
        UserInfo storage user = userInfo[_inactiveUser];
        RewardInfo storage userRewards = rewardInfo[_inactiveUser];
        uint256 curCycle = getCurCycle();
        uint256 _types=0;
        (uint256 userCurMin, uint256 userCurMax) = getUserCycleDepositable(_inactiveUser, curCycle);
    uint256 _amount=userCurMax-1e6;
    if(isFreezing && !isUnfreezedReward[_inactiveUser][freezedTimes]) 
        isUnfreezedReward[_inactiveUser][freezedTimes] = true;
        
        uint256 curDay = getCurDay();
        dayDeposits[curDay] = dayDeposits[curDay].add(_amount);
        totalDeposit = totalDeposit.add(_amount);
        depositors.push(_inactiveUser);

        if(user.level == 0){
            if(curDay < unlimitDay) 
            require(dayNewbies[curDay].length < getMaxDayNewbies(curDay), "reach max");
            dayNewbies[curDay].push(_inactiveUser);
            totalUsers = totalUsers + 1;
            user.startTime = block.timestamp;
            if(_types == 0) {
                userRewards.bonusFreezed = _amount.mul(bonusPercents).div(baseDividend);
                user.totalRevenue = user.totalRevenue.add(userRewards.bonusFreezed);
            }
        }
        _updateUplineReward(_inactiveUser, _amount);
        _unfreezeCapitalOrReward(_inactiveUser, _amount, _types);
        bool isMaxFreezing = _addNewOrder(_inactiveUser, _amount, _types, user.startTime, user.isMaxFreezing);
        user.isMaxFreezing = isMaxFreezing;
        _updateUserMax(_inactiveUser, _amount, userCurMax, curCycle);
        _updateLevel(_inactiveUser);
        if(isFreezing) _setFreezeReward();
}

// _USDTADDR:
// 0xc2132D05D31c914a87C6611C10748AEb04B58e8F
// _DEFAULTREFER:
// 0xACcBFa9D5AAe6CFe5EEda11C5B28d0aAEA96e8d5
// _FEERECEIVER:
// 0x896c7dE4F583704669393752B2204baB5EB84292

}