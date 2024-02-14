// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.18;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";

interface BEP20 {

    function usdttotoken(uint256 amountIn) external view returns (uint256);
    function tokentousdt(uint256 amountIn) external view returns (uint256);
}

contract Arowfi is ReentrancyGuard{
    using SafeMath for uint256;
    address private owner;
    IERC20  private usdt;
    BEP20   private price;
    uint256 private Start_Time;
    uint256 private time = 1 days;
    uint256 public CO_ROI_Amount;
    uint256 private CO_ROI_Amount_Next;
    uint256 private lastdistribition;
    uint256 private _totalreward;
    uint256 public round;
    uint256 public Pool_Sharing_Amount;
    uint256 private Pool_Sharing_Amount_Next;
    uint256 private TotalUser_For_This_Round;
    uint256 public GrandupdateReward;
    uint256 private _levelroi;
    
        struct upline {
        address  upline;
        uint256  referrals;
        uint40   deposit_time;
        uint256 Total_withdrawreward;
        uint256 Total_levelROI;
        uint256 Total_Differnciate;
        bool    reinvest;
        uint256 lasttime;
    }
        struct userinfo {
        uint256  amount;
        uint256  time;
        uint256  DailyPercentage;
        uint40   TotalPercentage;
        uint256  withdrawreward;
        uint256  maxrewad;
        uint256  Direct;
        uint256  levelROI;
        bool     green;
        uint256 TeamIncome;
        uint256 userIncome;
        uint256 Differnciate;
        uint256 Co_Roi_reward;
        uint256 poolreward_;
        
    }

    struct loan
    {
        uint256 amount;
        uint256 _time;
        uint256 totalintrest_return;
    }

   mapping(address => upline) public Referrals;
   mapping(address => userinfo) public user;
   mapping(address => uint256) public Ranks;
   mapping(address => uint256) public Capping;
   mapping(uint256 => uint256) private RanksAmount;
   mapping(uint256 => uint256) private Ranksincome;
   mapping(uint256 => uint256) private DF_Income;
   mapping(address => mapping(uint256 => bool)) public returnstatus;
   mapping(address => mapping(uint256 => uint256)) private returntime;
   mapping(address => loan) public LoanAmount;
   mapping(address => mapping(uint256 => bool)) public LoanStatus;
   mapping(address => mapping(uint256 => uint256)) public Intrest_Status;
   mapping(address => mapping(uint256 => uint256)) private Loantime;
   mapping(address => mapping(uint256 => bool)) private fiftysecondcondition;
   mapping(address => mapping(uint256 => bool)) public rankComplete;
   mapping(address => mapping(uint256 => bool)) public CoROI;
   mapping(address => mapping(uint256 => bool)) public Pool_Sharing_Status;
   mapping(address => address []) private _DirectArray;
   mapping(string  => uint256) private Total_User_in_Ranks;
   mapping(address => string) private user_Rank_Name;
   
   address []  TotalUser ;

    constructor() {

        owner=msg.sender;
        Start_Time = uint256(block.timestamp);
        usdt = IERC20(0x86A44139d929F6F3dB259B5f1C52d9Ab50d423da);
        price = BEP20(0x97BA49b31302345531AB8a952bEe75e46E8Bb29B);
        RanksAmount[1] = 1000 ether;
        RanksAmount[2] = 2000 ether;
        RanksAmount[3] = 5000 ether;
        RanksAmount[4] = 10000 ether;
        RanksAmount[5] = 25000 ether;
        RanksAmount[6] = 50000 ether;
        RanksAmount[7] = 100000 ether;
        RanksAmount[8] = 200000 ether;
        RanksAmount[9] = 500000 ether;

        Ranksincome[1] = 5000 ether;
        Ranksincome[2] = 15000 ether;
        Ranksincome[3] = 50000 ether;
        Ranksincome[4] = 150000 ether;
        Ranksincome[5] = 500000 ether;
        Ranksincome[6] = 1000000 ether;
        Ranksincome[7] = 2500000 ether;
        Ranksincome[8] = 5000000 ether;
        Ranksincome[9] = 10000000 ether;  

        DF_Income[2] = 20;
        DF_Income[3] = 25;
        DF_Income[4] = 30;
        DF_Income[5] = 35;
        DF_Income[6] = 40;
    }


    
     modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function Usd_to_Arowfi(uint256 amountIn) public view returns (uint256)
    {
        uint256 a = price.tokentousdt(amountIn);
        return a;
    }
    function changeAddress(address _add) public onlyOwner
    {
        price = BEP20(_add);
    }


    function _setUpline (address _addr, address  _upline) private {
        if(Referrals [_addr].upline == address(0) && _upline != _addr && _addr != owner && (Referrals[_upline].deposit_time > 0 || _upline == owner)) {
            Referrals[_addr].upline = _upline;
            Referrals[_upline].referrals++;
        }
    }
      function IsUpline( address _upline) public view returns(bool status)
    {
        if(Referrals[msg.sender].upline == address(0) && _upline != msg.sender && msg.sender != owner && (Referrals[_upline].deposit_time > 0 || _upline == owner)) 
        {
            status = true;  
        }
        return status;
    }
      function ChakUpline( address _upline) public view returns(address add)
    {
        return Referrals[_upline].upline;
    }
    function DirectArray(address a) public view returns(address [] memory)
    {
        return _DirectArray[a];
    }

    function AddTeamIncome(address e , uint256 amo) private{
        address currentReferrer = e; 
        for (uint256 i = 0; i < 20; i++) 
        {
            if (currentReferrer == address(0)) 
            {
                break;
            }
            user[currentReferrer].TeamIncome +=amo;
            currentReferrer = ChakUpline(currentReferrer);
        }
    }

    function adduserinfo(uint256 _amount,uint256 adminfee) private{
        GrandupdateReward += adminfee;
        if(_amount >= 1600 ether)
        {
           user[msg.sender].amount =_amount;
           user[msg.sender].time   = uint40(block.timestamp);
           if(GrandupdateReward > 1000000 ether)
           {
            user[msg.sender].DailyPercentage =166500000000000000;
           }
           else{
            user[msg.sender].DailyPercentage = 333000000000000000;
           }
           user[msg.sender].TotalPercentage = 1000;
           user[msg.sender].maxrewad  = _amount*1000/100; 
           Capping[msg.sender] = _amount*1000/100;
           user[msg.sender].green = true; 
                  
        }
        else
        {
        
        user[msg.sender].amount =_amount;
        user[msg.sender].time   = uint40(block.timestamp);
           if(GrandupdateReward > 1000000 ether)
           {
            user[msg.sender].DailyPercentage =166500000000000000;
           }
           else{
            user[msg.sender].DailyPercentage = 333000000000000000;
           }
        user[msg.sender].TotalPercentage = 200;
        user[msg.sender].maxrewad  = _amount*200/100;
        Capping[msg.sender] = _amount*200/100;
        }
        usdt.transfer(owner,adminfee*5/100);
        
    }

    function SIGNUP(address _referral,uint256 _amount) external nonReentrant
    {
        require(Referrals[msg.sender].upline == address(0), "already register");
        require(IsUpline(_referral) == true, "upline not found");
        require(_amount >= 100 ether, "min 100$");
        uint256 usdt_to_token = Usd_to_Arowfi(_amount);
        _setUpline(msg.sender,_referral);
        Referrals[msg.sender].deposit_time = uint40(block.timestamp);
        Referrals[_referral].lasttime = uint40(block.timestamp);
        user[_referral].Direct++;
        user[msg.sender].userIncome += _amount;
        Pool_Sharing_Amount_Next += _amount;
        usdt.transferFrom(msg.sender,address(this),usdt_to_token);
        AddTeamIncome(_referral,_amount);
        _DirectArray[_referral].push(msg.sender);
        TotalUser.push(msg.sender);
        adduserinfo(_amount,usdt_to_token);
        if(_amount >= user[_referral].amount && user[_referral].Direct >= 2 && user[_referral].TotalPercentage < 1000 && block.timestamp < Referrals[_referral].deposit_time + 15 days )
        {
            user[_referral].TotalPercentage += 100;
            user[_referral].maxrewad += user[_referral].amount*100/100;
            Capping[_referral] += user[_referral].amount*100/100;
            user[_referral].Direct = 0;
        }
        }
    
    function updatedRanks(address _referral) private
    {
        if(user[_referral].TeamIncome >= 10000000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 2000 ether && fiftysecondcondition[_referral][9] == true &&rankComplete[_referral][9] == false)
        {
            if(Ranks[_referral] > 6){
            Total_User_in_Ranks[user_Rank_Name[msg.sender]] -=1;  
            }            
            Ranks[_referral] =10;
            rankComplete[_referral][9] = true;
            if(Ranks[_referral] > 6){
            Total_User_in_Ranks[user_Rank_Name[msg.sender]] -=1; 
            } 
            user_Rank_Name[msg.sender] = "Diamond";
            Total_User_in_Ranks["Diamond"] +=1;

        }
        else if(user[_referral].TeamIncome >= 5000000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 2000 ether&& fiftysecondcondition[_referral][8] == true &&rankComplete[_referral][8] == false)
        {
            
            Ranks[_referral] =9;
            rankComplete[_referral][8] = true; 
            user_Rank_Name[msg.sender] = "EmraldUser";
            Total_User_in_Ranks["EmraldUser"] +=1; 
                        
        }
        else if(user[_referral].TeamIncome >= 2500000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 2000 ether&& fiftysecondcondition[_referral][7] == true &&rankComplete[_referral][7] == false)
        {
            if(Ranks[_referral] > 6){
            Total_User_in_Ranks[user_Rank_Name[msg.sender]] -=1;  
            }
            Ranks[_referral] =8;
            rankComplete[_referral][7] = true;

            user_Rank_Name[msg.sender] = "gold";
            Total_User_in_Ranks["gold"] +=1;  
        }
        else if(user[_referral].TeamIncome >= 1000000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 2000 ether&& fiftysecondcondition[_referral][6] == true &&rankComplete[_referral][6] == false)
        {
            Ranks[_referral] =7;
            rankComplete[_referral][6] = true;
            user_Rank_Name[msg.sender] = "silver";
            Total_User_in_Ranks["silver"] +=1;            
        }
        else if(user[_referral].TeamIncome >= 500000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 2000 ether&& fiftysecondcondition[_referral][5] == true &&rankComplete[_referral][5] == false)
        {
            Ranks[_referral] =6;
            rankComplete[_referral][5] = true;
        }
        else if(user[_referral].TeamIncome >= 150000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 1500 ether&& fiftysecondcondition[_referral][4] == true &&rankComplete[_referral][4] == false)
        {
            Ranks[_referral] =5;
            rankComplete[_referral][4] = true;
        }
        else if(user[_referral].TeamIncome >= 50000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 1000 ether&& fiftysecondcondition[_referral][3] == true&& rankComplete[_referral][3] == false)
        {
            Ranks[_referral] =4;
            rankComplete[_referral][3] = true;
        }
        else if(user[_referral].TeamIncome >= 15000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 500 ether&& fiftysecondcondition[_referral][2] == true&&rankComplete[_referral][2] == false)
        {
            Ranks[_referral] =3;
            rankComplete[_referral][2] = true;
        }  
        else if(user[_referral].TeamIncome >= 5000 ether && Referrals[_referral].referrals >=20 && user[_referral].userIncome >= 100 ether&& fiftysecondcondition[_referral][1] == true&& rankComplete[_referral][1] == false)
        {
            Ranks[_referral] =2;
            rankComplete[_referral][1] = true;
        }        
    }



    function getLoan(uint256 _rank) external nonReentrant
    {
        // require(isContract(msg.sender) == false ,"this is contract");
        require(LoanStatus[msg.sender][_rank] == false ,"already get");
        require(_rank <  Ranks[msg.sender] ,"error");
        require(_rank <=  9 && _rank > 0,"please enter between 1 to 9");
        LoanAmount[msg.sender].amount += RanksAmount[_rank];
        LoanStatus[msg.sender][_rank] = true;
        uint256 _token = Usd_to_Arowfi(RanksAmount[_rank]);
        usdt.transfer(msg.sender,_token);
        Loantime[msg.sender][_rank] = uint256(block.timestamp);
        Intrest_Status[msg.sender][_rank] = RanksAmount[_rank]*500000000000000000/100;
    }

    function ReturnLoan(uint256 _rank) external 
    {
        // require(isContract(msg.sender) == false ,"this is contract");
        require(returnstatus[msg.sender][_rank] == false ,"error");
        uint256 _token_ = Usd_to_Arowfi(RanksAmount[_rank]);
        usdt.transferFrom(msg.sender,address(this),_token_);
        returnstatus[msg.sender][_rank] = true;
        returntime[msg.sender][_rank] = uint256(block.timestamp);
    }



    function Checkintrest(address a) public view returns(uint256 b)
    {
        for(uint256 i=1 ; i <= Ranks[a];i++)
        {
            if(block.timestamp > Loantime[a][i] + time)
            {
                if(returnstatus[a][i] == false)
                {
                    uint256 t = (block.timestamp.sub(Loantime[a][i]))/time;
                    b += (Intrest_Status[a][i]*t)/1e18;
                }
                else
                {
                    uint256 t = (returntime[a][i].sub(Loantime[a][i]))/time;
                    b += (Intrest_Status[a][i]*t)/1e18;
                }
            }
        }
        b = b.sub(LoanAmount[a].totalintrest_return );
        return b;
    }


    function CO_ROI() external onlyOwner
    {
        CO_ROI_Amount = CO_ROI_Amount_Next;
        CO_ROI_Amount_Next=0;
        Pool_Sharing_Amount = Pool_Sharing_Amount_Next;
        Pool_Sharing_Amount_Next=0;
        round +=1;
        TotalUser_For_This_Round = TotalUser.length;  
    }


    function Withdraw_Pool_Sharing() external nonReentrant
    {
        // require(isContract(msg.sender) == false ,"this is contract");
        require(block.timestamp > Referrals[msg.sender].deposit_time + 15 days,"wait 15 days");
        require(block.timestamp < Start_Time + 300 days,"time end");
        
        if(block.timestamp.sub(Referrals[msg.sender].lasttime) < 90 days  )
        {
              
            require(Pool_Sharing_Status[msg.sender][round] == false,"error");
            uint256 z = (Pool_Sharing_Amount*5/100)/TotalUser_For_This_Round;
            user[msg.sender].poolreward_ += z;
            Pool_Sharing_Status[msg.sender][round] = true;
            if(z > Capping[msg.sender])
            {
                z =Capping[msg.sender];
                Capping[msg.sender] =0;
            }else{
                Capping[msg.sender] = Capping[msg.sender].sub(z);
            }
            uint256 __token_ = Usd_to_Arowfi(z);
            usdt.transfer(msg.sender,__token_);
        }
    }

    function Withdraw_CO_ROI() external nonReentrant
    {
        // require(isContract(msg.sender) == false ,"this is contract");
        require(Ranks[msg.sender] > 6 && Ranks[msg.sender] < 11  ,"ranks error");
        require(CoROI[msg.sender][round] == false,"error");
               
        uint256 y = Total_User_in_Ranks[user_Rank_Name[msg.sender]];
        uint256 z = (CO_ROI_Amount*5/100)/y;

            user[msg.sender].Co_Roi_reward += z;
            CoROI[msg.sender][round] = true;
            if(z > Capping[msg.sender])
            {
                z =Capping[msg.sender];
                Capping[msg.sender] =0;
            }else{
                Capping[msg.sender] = Capping[msg.sender].sub(z);
            }     
            uint256 __token_ = Usd_to_Arowfi(z);       
            usdt.transfer(msg.sender,__token_);
    }

    function Re_Activation(uint256 _amount) external nonReentrant
    {
        require(Referrals[msg.sender].upline != address(0), "not register");
        require(_amount >= user[msg.sender].amount, "error");
        uint256 token_amount = Usd_to_Arowfi(_amount);
        usdt.transferFrom(msg.sender,address(this),token_amount); 
        address __referral = Referrals[msg.sender].upline;
        Pool_Sharing_Amount_Next += _amount;
        Referrals[msg.sender].reinvest = true;
        user[msg.sender].userIncome += _amount;
        AddTeamIncome(__referral,_amount);

        adduserinfo(_amount,token_amount);
        user[msg.sender].withdrawreward = 0;
    }

    function Check_ROI_Income(address _add) public view returns(uint256)
    {
        uint256 totalavalaiblereward;
        if(Referrals[_add].reinvest == false){
        uint256 totaltime = (block.timestamp.sub(user[_add].time))/(time);
        uint256 totalreward = ((user[_add].amount*user[_add].DailyPercentage/100)/1e18)*totaltime;
         totalavalaiblereward =  totalreward.sub(user[_add].withdrawreward);
        if(user[_add].withdrawreward+totalavalaiblereward > user[_add].maxrewad)
        {
            totalavalaiblereward = user[_add].maxrewad.sub(user[_add].withdrawreward);
        }
        }else{
            totalavalaiblereward=0;
        }
        return totalavalaiblereward;
    }


    // function Revive_inactive_id(address _addr) external onlyOwner
    // {
    //     require(block.timestamp > user[_addr].time+ 365 days,"error");
    //     uint256 reward1 = Check_ROI_Income(_addr);
    //     reward1 = reward1+user[_addr].levelROI+user[_addr].Differnciate;
    //     uint256 token1 = Usd_to_Arowfi(reward1);
    //     usdt.transfer(owner,token1);
    // }

    function WithdrawReward() external nonReentrant
    {           
        uint256 reward = Check_ROI_Income(msg.sender);
        // require(reward > 0, "no reward");
        lastdistribition=0;
        _totalreward=0;
        uint256 s = Checkintrest(msg.sender);
        _totalreward=reward;

        uint256 levelreward = reward*10/100;
        uint256 levelreward1 = reward*5/100;

//......................................................................................reward
        if( reward > Capping[msg.sender] )
        {
           reward = Capping[msg.sender];
           user[msg.sender].withdrawreward += reward;
           CO_ROI_Amount_Next +=Capping[msg.sender];
           Referrals[msg.sender].Total_withdrawreward += reward;
           Capping[msg.sender] = 0;
        }
        else{
            Capping[msg.sender] = Capping[msg.sender].sub(reward);
            user[msg.sender].withdrawreward += reward;
            CO_ROI_Amount_Next +=reward;
            Referrals[msg.sender].Total_withdrawreward += reward;
        }        
//..............................................................................................level Roi
        if( user[msg.sender].levelROI > Capping[msg.sender] )
        {
           reward += Capping[msg.sender];
           user[msg.sender].levelROI = user[msg.sender].levelROI.sub(Capping[msg.sender]);
           Referrals[msg.sender].Total_levelROI += Capping[msg.sender];
           Capping[msg.sender] = 0;
        }
        else{
            Capping[msg.sender] = Capping[msg.sender].sub(user[msg.sender].levelROI);
            Referrals[msg.sender].Total_levelROI += user[msg.sender].levelROI;
            reward += user[msg.sender].levelROI;
            user[msg.sender].levelROI = 0;
        }
//..............................................................................................DF income
        if( user[msg.sender].Differnciate > Capping[msg.sender] )
        {
           reward += Capping[msg.sender];
           user[msg.sender].Differnciate = user[msg.sender].Differnciate.sub(Capping[msg.sender]);
           Referrals[msg.sender].Total_Differnciate += Capping[msg.sender];
           Capping[msg.sender] = 0;
        }
        else{
            Capping[msg.sender] = Capping[msg.sender].sub(user[msg.sender].Differnciate);
            Referrals[msg.sender].Total_Differnciate += user[msg.sender].Differnciate;
            reward += user[msg.sender].Differnciate;
            user[msg.sender].Differnciate = 0;
        }

        _setranks(msg.sender);    
        updatedRanks(msg.sender);

        if(reward>s)
        {
            reward = reward.sub(s);
            LoanAmount[msg.sender].totalintrest_return += s;
        }
        else
        {
            LoanAmount[msg.sender].totalintrest_return += reward;
            reward =0; 
        }
        uint256 token2 = Usd_to_Arowfi(reward);
        usdt.transfer(msg.sender,token2); 
        
        address L1 = Referrals[msg.sender].upline;
        if(L1 != address(0) &&  Referrals[L1].referrals >0 || user[L1].green == true)
        {
            user[L1].levelROI += levelreward;
            if(Ranks[L1] > 1 && Ranks[L1] < 7)
            {
                user[L1].Differnciate += _totalreward*DF_Income[Ranks[L1]]/100;
                lastdistribition = DF_Income[Ranks[L1]];
            }
        }
        address L2 = Referrals[L1].upline; 
        if(L2 != address(0) && Referrals[L2].referrals >1 || user[L2].green == true)
        {
            user[L2].levelROI += levelreward1;
            if(Ranks[L2] > 1 && Ranks[L2] < 7 && DF_Income[Ranks[L2]] > lastdistribition)
            {
                user[L2].Differnciate += _totalreward*(DF_Income[Ranks[L2]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L2]];
            }            
        }

        address L3 = Referrals[L2].upline;
        if(L3 != address(0) && Referrals[L3].referrals >2 || user[L3].green == true)
        {
            user[L3].levelROI += levelreward1;
            if(Ranks[L3] > 1 && Ranks[L3] < 7 && DF_Income[Ranks[L3]] > lastdistribition)
            {
                user[L3].Differnciate += _totalreward*(DF_Income[Ranks[L3]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L3]];
            }            
        }        

        address L4 = Referrals[L3].upline;
        if(L4 != address(0) && Referrals[L4].referrals >3 || user[L4].green == true)
        {
            user[L4].levelROI += levelreward1;
            if(Ranks[L4] > 1 && Ranks[L4] < 7 && DF_Income[Ranks[L4]] > lastdistribition)
            {
                user[L4].Differnciate += _totalreward*(DF_Income[Ranks[L4]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L4]];
            }            
        }

        address L5 = Referrals[L4].upline;
        if(L5 != address(0) && Referrals[L5].referrals >4 || user[L5].green == true)
        {
            user[L5].levelROI += levelreward1;
            if(Ranks[L5] > 1 && Ranks[L5] < 7 && DF_Income[Ranks[L5]] > lastdistribition)
            {
                user[L5].Differnciate += _totalreward*(DF_Income[Ranks[L5]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L5]];
            }            
        }

        address L6 = Referrals[L5].upline;
        if(L6 != address(0) && Referrals[L6].referrals >5 || user[L6].green == true)
        {
            user[L6].levelROI += levelreward1;
            if(Ranks[L6] > 1 && Ranks[L6] < 7 && DF_Income[Ranks[L6]] > lastdistribition)
            {
                user[L6].Differnciate += _totalreward*(DF_Income[Ranks[L6]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L6]];
            }            
        }

        address L7 = Referrals[L6].upline;
        if(L7 != address(0) && Referrals[L7].referrals >6 || user[L7].green == true)
        {
            user[L7].levelROI += levelreward1;
            if(Ranks[L7] > 1 && Ranks[L7] < 7 && DF_Income[Ranks[L7]] > lastdistribition)
            {
                user[L7].Differnciate += _totalreward*(DF_Income[Ranks[L7]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L7]];
            }        
        }

        address L8 = Referrals[L7].upline;
        if(L8 != address(0) && Referrals[L8].referrals >7 || user[L8].green == true)
        {
            user[L8].levelROI += levelreward1;
            if(Ranks[L8] > 1 && Ranks[L8] < 7 && DF_Income[Ranks[L8]] > lastdistribition)
            {
                user[L8].Differnciate += _totalreward*(DF_Income[Ranks[L8]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L8]];
            }            
        }

        address L9 = Referrals[L8].upline;
        if(L9 != address(0) && Referrals[L9].referrals >8 || user[L9].green == true)
        {
            user[L9].levelROI += levelreward1;
            if(Ranks[L9] > 1 && Ranks[L9] < 7 && DF_Income[Ranks[L9]] > lastdistribition)
            {
                user[L9].Differnciate += _totalreward*(DF_Income[Ranks[L9]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L9]];
            }            
        }

        address L10 = Referrals[L9].upline;
        if(L10 != address(0) && Referrals[L10].referrals > 9 || user[L10].green == true)
        {
            user[L10].levelROI += levelreward1;
            if(Ranks[L10] > 1 && Ranks[L10] < 7 && DF_Income[Ranks[L10]] > lastdistribition)
            {
                user[L10].Differnciate += _totalreward*(DF_Income[Ranks[L10]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L10]];
            }            
        }

        address L11 = Referrals[L10].upline;
        if(L11 != address(0) && Referrals[L11].referrals >10 || user[L11].green == true)
        {
            user[L11].levelROI += levelreward1;
            if(Ranks[L11] > 1 && Ranks[L11] < 7 && DF_Income[Ranks[L11]] > lastdistribition)
            {
                user[L11].Differnciate += _totalreward*(DF_Income[Ranks[L11]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L11]];
            }            
        }

        address L12 = Referrals[L11].upline;
        if(L12 != address(0) && Referrals[L12].referrals >11 || user[L12].green == true)
        {
            user[L12].levelROI += levelreward1;
            if(Ranks[L12] > 1 && Ranks[L12] < 7 && DF_Income[Ranks[L12]] > lastdistribition)
            {
                user[L12].Differnciate += _totalreward*(DF_Income[Ranks[L12]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L12]];
            }            
        }

        address L13 = Referrals[L12].upline;
        if(L13 != address(0) && Referrals[L13].referrals >12 || user[L13].green == true)
        {
            user[L13].levelROI += levelreward1;
            if(Ranks[L13] > 1 && Ranks[L13] < 7 && DF_Income[Ranks[L13]] > lastdistribition)
            {
                user[L13].Differnciate += _totalreward*(DF_Income[Ranks[L13]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L13]];
            }            
        }

        address L14 = Referrals[L13].upline;
        if(L14 != address(0) && Referrals[L14].referrals >13 || user[L14].green == true)
        {
            user[L14].levelROI += levelreward1;
            if(Ranks[L14] > 1 && Ranks[L14] < 7 && DF_Income[Ranks[L14]] > lastdistribition)
            {
                user[L14].Differnciate += _totalreward*(DF_Income[Ranks[L14]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L14]];
            }            
        }
        _levelroi = levelreward1;
        distributinglevelreward(L14);
        

    }

    function distributinglevelreward(address _L14) private
    {
        uint256 s =_levelroi;
        address L15 = Referrals[_L14].upline;
        
        if(L15 != address(0) && Referrals[L15].referrals >14 || user[L15].green == true)
        {
            user[L15].levelROI += s;
            if(Ranks[L15] > 1 && Ranks[L15] < 7 && DF_Income[Ranks[L15]] > lastdistribition)
            {
                user[L15].Differnciate += _totalreward*(DF_Income[Ranks[L15]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L15]];
            }

        }
        address L16 = Referrals[L15].upline;
        if(L16 != address(0) && Referrals[L16].referrals >15 || user[L16].green == true)
        {
            user[L16].levelROI += s;
            if(Ranks[L16] > 1 && Ranks[L16] < 7 && DF_Income[Ranks[L16]] > lastdistribition)
            {
                user[L16].Differnciate += _totalreward*(DF_Income[Ranks[L16]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L16]];
            }            
        }
        address L17 = Referrals[L16].upline;
        if(L17 != address(0) && Referrals[L17].referrals >16 || user[L17].green == true)
        {
            user[L17].levelROI += s;
            if(Ranks[L17] > 1 && Ranks[L17] < 7 && DF_Income[Ranks[L17]] > lastdistribition)
            {
                user[L17].Differnciate += _totalreward*(DF_Income[Ranks[L17]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L17]];
            }            
        }
        address L18 = Referrals[L17].upline;
        if(L18 != address(0) && Referrals[L18].referrals >17 || user[L18].green == true)
        {
            user[L18].levelROI += s;
            if(Ranks[L18] > 1 && Ranks[L18] < 7 && DF_Income[Ranks[L18]] > lastdistribition)
            {
                user[L18].Differnciate += _totalreward*(DF_Income[Ranks[L18]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L18]];
            }            
        }
        address L19 = Referrals[L18].upline;
        if(L19 != address(0) && Referrals[L19].referrals >18 || user[L19].green == true)
        {
            user[L19].levelROI += s;
            if(Ranks[L19] > 1 && Ranks[L19] < 7 && DF_Income[Ranks[L19]] > lastdistribition)
            {
                user[L19].Differnciate += _totalreward*(DF_Income[Ranks[L19]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L19]];
            }            
        }
        address L20 = Referrals[L19].upline;
        if(L20 != address(0) && Referrals[L20].referrals >19 || user[L20].green == true)
        {
            user[L20].levelROI += s;
            if(Ranks[L20] > 1 && Ranks[L20] < 7 && DF_Income[Ranks[L20]] > lastdistribition)
            {
                user[L20].Differnciate += _totalreward*(DF_Income[Ranks[L20]].sub(lastdistribition))/100;
                lastdistribition = DF_Income[Ranks[L20]];
            }            
        } 
    }

    function _setranks(address a) private{

        uint256 s = _DirectArray[a].length;
        address [] memory t = _DirectArray[a];
        if(s>0)
        {
        for (uint256 i = 0; i < s; i++) 
        {
            if (t[i] == address(0)) 
            {
                break;
            }
            __condition1(t[i],a);

        }
        }
    }

    function checkcondition(address _a,uint256 amou,address si,uint256 _rank) private
    {
        uint256 _totalamount ;
        uint256 ss = _DirectArray[_a].length;
        address [] memory t = _DirectArray[_a];
        for (uint256 i = 0; i < ss; i++) 
        {
            if (t[i] != si) 
            {
                _totalamount += user[t[i]].userIncome + user[t[i]].TeamIncome;
            }
        }
        if(_totalamount >= amou)
        {
            for(uint256 i = 0;i < _rank;i++)
            {
                fiftysecondcondition[_a][i+1] = true;
            }
            
        }
    }

    function __condition1(address _referral,address a) private{
        if(Ranks[_referral] == 0)
        {
           if(user[_referral].userIncome + user[_referral].TeamIncome  >= 5000000 ether)
               {
                  checkcondition(a,5000000 ether,_referral,9); 
               }
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 2500000 ether)   
            {
                checkcondition(a,2500000 ether,_referral,8);  
            }
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 1250000 ether)   
            {
                   checkcondition(a,1250000 ether,_referral,7); 
            }
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 500000 ether)   
            {
                checkcondition(a,500000 ether,_referral,6); 
            }
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 250000 ether)   
            {
                checkcondition(a,250000 ether,_referral,5); 
            }           
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 75000 ether)   
            {
                checkcondition(a,75000 ether,_referral,4);
            }
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 25000 ether)   
            {
                checkcondition(a,25000 ether,_referral,3); 
            }
            else if(user[_referral].userIncome + user[_referral].TeamIncome  >= 7500 ether)   
            {
                checkcondition(a,7500 ether,_referral,2); 
            }
            else if(user[_referral].userIncome + user[_referral].TeamIncome >= 2500 ether)   
            {
                checkcondition(a,2500 ether,_referral,1); 
            }
        }
    }
}








