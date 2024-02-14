// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.0;

import "./ReentrancyGuard.sol";

contract Firewaves is ReentrancyGuard 
{
    using SafeMath for uint256;
    address private owner;
    IERC20  private usdt;
    uint256 public Start_Time;
    uint256 private time = 1 days;
    uint256 private  last_ref=1;
    struct upline {
        address  upline;
        uint256  referrals;
        uint40   deposit_time;
        uint256  totalearn;
    }
    struct addressreplace {
        address  upline;
        uint256   position;
        address  last_Left;
        address  last_right;
        address  left_side;
        address  right_side;
        uint256  Total_levelROI_left_side;
        uint256  Total_levelROI_right_side;        
    }
    struct userinfo {
        uint256  amount;
        uint256  time;
        uint256  DailyPercentage;
        uint40   TotalPercentage;
        uint256  withdrawreward;
        uint256  maxrewad;
        uint256  capping;
        uint256  levelROI_left_side;
        uint256  levelROI_right_side;
        uint256  TeamIncome;
        uint256  userIncome;
        uint256  owner_levelROI;
        bool     stop;
    }
    struct Pool {
        uint256  upline;
        uint256  Direct;
        uint256  global_income;
        bool      P1;
        uint256  grandAmount;
        bool     P1_Done;
        bool     P1_1st;
        uint256  Withdrawable_Amount;
    }
   mapping(address => upline) public Referrals;
   mapping(uint256 => Pool) public Global_Pool_One;
   mapping(uint256 => Pool) public Global_Pool_two;
   mapping(uint256 => Pool) public Global_Pool_three;
   mapping(uint256 => Pool) public Global_Pool_four;
   mapping(uint256 => Pool) public Global_Pool_five;
   mapping(uint256 => Pool) public Global_Pool_six;
   mapping(uint256 => Pool) public Global_Pool_seven;
   mapping(uint256 => Pool) public Global_Pool_eight;
   mapping(uint256 => Pool) public Global_Pool_nine;
   mapping(uint256 => Pool) public Global_Pool_Ten;
   mapping(address => addressreplace) public ReplaceBy;
   mapping(address => userinfo) public user;
   mapping(address => userinfo) public users;
   mapping(address => address []) public _DirectArray;
   mapping(uint256 => uint256 []) private Global_DirectArray;
   mapping(address => mapping(uint256 => bool)) private Position_status;
   mapping(address => mapping(address => uint256)) private Position_to_raffar;
   uint256 [] private TotalUser1 ;
   address [] private TotalUser ;
   uint256 private index = 1;
   uint256 private distribution_index =0;
   address private Add1;
   address private Add2;
    constructor() {
        owner=msg.sender;
        Start_Time = uint256(block.timestamp);
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        Add1 = (0x4890BF1c5c772c76FD84c8CD84aDFA65Cf3c5e87);
        Add2 = (0xD30Cb352A73212B698CB081C5EB8E1C1185FCfe2);
        ReplaceBy[owner].last_Left = msg.sender;
        ReplaceBy[owner].last_right =msg.sender;
        Global_Pool_1(msg.sender);
        Global_Pool_2(1); 
        Global_Pool_3(1);
        Global_Pool_4(1);
        Global_Pool_5(1);
        Global_Pool_6(1);
        Global_Pool_7(1);
        Global_Pool_8(1);
        Global_Pool_9(1);
        Global_Pool_10(1);        
       
    }  
     modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    uint256 private Ids = 1;
    mapping(uint256 => address) private addresstoid;
    mapping(address => uint256) private userlastId;
    mapping(address => uint256 []) private userids;
    function Check_userids(address a) public view returns(uint256 [] memory){
        return userids[a];
    }

   
      function Withdraw_global_Reward() external nonReentrant { 
        uint256 reward;
        for(uint256 i=0; i < userids[msg.sender].length;i++)
        {
            uint256 _add =userids[msg.sender][i];
            reward += Global_Pool_One[_add].Withdrawable_Amount;
            Global_Pool_One[_add].Withdrawable_Amount=0;
        }
        if(userids2[msg.sender].length >0){
        for(uint256 i=0; i < userids2[msg.sender].length;i++)
        {
            uint256 _add =userids2[msg.sender][i];
            reward += Global_Pool_two[_add].Withdrawable_Amount;
            Global_Pool_two[_add].Withdrawable_Amount=0;
        }
        }
        if(userids3[msg.sender].length >0){
        for(uint256 i=0; i < userids3[msg.sender].length;i++)
        {
            uint256 _add =userids3[msg.sender][i];
            reward += Global_Pool_three[_add].Withdrawable_Amount;
            Global_Pool_three[_add].Withdrawable_Amount=0;
        }
        }
        if(userids4[msg.sender].length >0){
        for(uint256 i=0; i < userids4[msg.sender].length;i++)
        {
            uint256 _add =userids4[msg.sender][i];
            reward += Global_Pool_four[_add].Withdrawable_Amount;
            Global_Pool_four[_add].Withdrawable_Amount=0;
        }
        }
        if(userids5[msg.sender].length >0){
        for(uint256 i=0; i < userids5[msg.sender].length;i++)
        {
            uint256 _add =userids5[msg.sender][i];
            reward += Global_Pool_five[_add].Withdrawable_Amount;
            Global_Pool_five[_add].Withdrawable_Amount=0;
        }
        }     
        if(userids6[msg.sender].length >0){
        for(uint256 i=0; i < userids6[msg.sender].length;i++)
        {
            uint256 _add =userids6[msg.sender][i];
            reward += Global_Pool_six[_add].Withdrawable_Amount;
            Global_Pool_six[_add].Withdrawable_Amount=0;
        }
        }
        if(userids7[msg.sender].length >0){
        for(uint256 i=0; i < userids7[msg.sender].length;i++)
        {
            uint256 _add =userids7[msg.sender][i];
            reward += Global_Pool_seven[_add].Withdrawable_Amount;
            Global_Pool_seven[_add].Withdrawable_Amount=0;
        }
        }
        if(userids8[msg.sender].length >0){
        for(uint256 i=0; i < userids8[msg.sender].length;i++)
        {
            uint256 _add =userids8[msg.sender][i];
            reward += Global_Pool_eight[_add].Withdrawable_Amount;
            Global_Pool_eight[_add].Withdrawable_Amount=0;
        }
        }  
        if(userids9[msg.sender].length >0){
        for(uint256 i=0; i < userids9[msg.sender].length;i++)
        {
            uint256 _add =userids9[msg.sender][i];
            reward += Global_Pool_nine[_add].Withdrawable_Amount;
            Global_Pool_nine[_add].Withdrawable_Amount=0;
        }
        }    
          
        if(userids10[msg.sender].length >0){
        for(uint256 i=0; i < userids10[msg.sender].length;i++)
        {
            uint256 _add =userids10[msg.sender][i];
            reward += Global_Pool_Ten[_add].Withdrawable_Amount;
            Global_Pool_Ten[_add].Withdrawable_Amount=0;
        }
        } 
        Referrals[msg.sender].totalearn += reward;   
        require(reward >0 ,"error");     
        usdt.transfer(msg.sender,reward);        
    }

    function Global_Pool_1(address __add_) private{
            userlastId[__add_] = Ids;
            addresstoid[Ids] = __add_;
            TotalUser1.push(Ids);
            userids[__add_].push(Ids);
            Ids++;
        if(Global_Pool_One[last_ref].Direct < 2){
        Global_Pool_One[userlastId[__add_]].upline = last_ref;
        Global_Pool_One[last_ref].Direct++;
        Global_DirectArray[last_ref].push(userlastId[__add_]);
        }else{
            last_ref = TotalUser1[index];
            index++;
            Global_Pool_One[userlastId[__add_]].upline = last_ref;
            Global_Pool_One[last_ref].Direct++;  
            Global_DirectArray[last_ref].push(userlastId[__add_]);  
        }
        uint256 _add = Global_Pool_One[userlastId[__add_]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_One[_add].P1 == false)
                 {
                   Global_Pool_One[_add].global_income +=2 ether ;
                   usdt.transfer(addresstoid[_add], 2 ether);
                     if(Global_Pool_One[_add].global_income == 60 ether)
                       {
                         Global_Pool_One[_add].P1 = true;
                       }
                       _add = Global_Pool_One[_add].upline;
                 }else
                 {
                    Global_Pool_One[_add].grandAmount += 2 ether;
                    if(Global_Pool_One[_add].grandAmount == 64 ether)
                    {
                           Global_Pool_One[_add].P1_1st = true;
                           Global_Pool_One[_add].P1_Done = true;
                           Global_Pool_One[_add].Withdrawable_Amount += 14 ether;
                           Global_Pool_One[_add].grandAmount = 0;
                           Global_Pool_1(addresstoid[_add]);
                           Global_Pool_1(addresstoid[_add]);                           
                           Global_Pool_2(_add);
                    }
                    _add = Global_Pool_One[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }
    uint256 private last_ref2 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray2;
    mapping(address => uint256 ) private userlastId2;
    mapping(uint256 => address ) private addresstoid2;
    uint256 [] private TotalUser2 ;
    uint256 private index2 =1;
    uint256 private Ids2 =1;
    mapping(address => uint256 []) private userids2;
    function Check_userids2(address a) public view returns(uint256 [] memory){
        return userids2[a];
    }


    function Global_Pool_2(uint256 _add_) private{       
            address useraddress = addresstoid[_add_];
            userlastId2[useraddress] = Ids2;
            addresstoid2[Ids2] = useraddress;
            TotalUser2.push(Ids2);
            userids2[useraddress].push(Ids2);
            Ids2++;
        
        if(Global_Pool_two[last_ref2].Direct < 2){
        Global_Pool_two[userlastId2[useraddress]].upline = last_ref2;
        Global_Pool_two[last_ref2].Direct++;
        Global_DirectArray2[last_ref2].push(userlastId2[useraddress]);
        }else{
            last_ref2 = TotalUser2[index2];
            index2++;
            Global_Pool_two[userlastId2[useraddress]].upline = last_ref2;
            Global_Pool_two[last_ref2].Direct++;  
            Global_DirectArray[last_ref2].push(userlastId2[useraddress]);  
        }
        uint256 _add = Global_Pool_two[userlastId2[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_two[_add].P1 == false)
                 {
                   Global_Pool_two[_add].global_income +=6 ether ;
                   usdt.transfer(addresstoid2[_add], 6 ether);
                   
                     if(Global_Pool_two[_add].global_income == 180 ether)
                       {
                         Global_Pool_two[_add].P1 = true;
                       }
                       _add = Global_Pool_two[_add].upline;
                 }else
                 {
                    Global_Pool_two[_add].grandAmount += 6 ether;
                    if(Global_Pool_two[_add].grandAmount == 192 ether)
                    {
                           Global_Pool_two[_add].P1_1st = true;
                           Global_Pool_two[_add].P1_Done = true;
                           Global_Pool_two[_add].Withdrawable_Amount += 92 ether;
                           Global_Pool_two[_add].grandAmount = 0;
                           Global_Pool_1(addresstoid2[_add]);
                           Global_Pool_1(addresstoid2[_add]); 
                           Global_Pool_1(addresstoid2[_add]);
                           Global_Pool_1(addresstoid2[_add]);
                           Global_Pool_3(_add);     
                    }
                    _add = Global_Pool_two[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }
    uint256 private last_ref3 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray3;
    mapping(address => uint256 ) private userlastId3;
    mapping(uint256 => address )private addresstoid3;
    uint256 [] private TotalUser3 ;
    uint256 private index3 =1;
    uint256 private Ids3 =1;
    mapping(address => uint256 []) private userids3;
    function Check_userids3(address a) public view returns(uint256 [] memory){
        return userids3[a];
    }
    function Global_Pool_3(uint256 _add_) private{       
            address useraddress = addresstoid2[_add_];
            userlastId3[useraddress] = Ids2;
            addresstoid3[Ids3] = useraddress;
            TotalUser3.push(Ids3);
            userids3[useraddress].push(Ids3);
            Ids3++;
        
        if(Global_Pool_three[last_ref3].Direct < 2){
        Global_Pool_three[userlastId3[useraddress]].upline = last_ref3;
        Global_Pool_three[last_ref3].Direct++;
        Global_DirectArray3[last_ref3].push(userlastId3[useraddress]);
        }else{
            last_ref3 = TotalUser3[index3];
            index3++;
            Global_Pool_three[userlastId3[useraddress]].upline = last_ref3;
            Global_Pool_three[last_ref3].Direct++;  
            Global_DirectArray[last_ref3].push(userlastId3[useraddress]);  
        }
        uint256 _add = Global_Pool_three[userlastId3[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_three[_add].P1 == false)
                 {
                   Global_Pool_three[_add].global_income += 12 ether ;
                   usdt.transfer(addresstoid2[_add], 12 ether);
                   
                     if(Global_Pool_three[_add].global_income == 360 ether)
                       {
                         Global_Pool_three[_add].P1 = true;
                       }
                       _add = Global_Pool_three[_add].upline;
                 }else
                 {
                    Global_Pool_three[_add].grandAmount += 12 ether;
                    if(Global_Pool_three[_add].grandAmount == 384 ether)
                    {
                        // if(Global_Pool_two[_add].P1_1st == false)
                        //  {
                           Global_Pool_three[_add].P1_1st = true;
                           Global_Pool_three[_add].P1_Done = true;
                           Global_Pool_three[_add].Withdrawable_Amount += 184 ether;
                           Global_Pool_three[_add].grandAmount = 0;
                           for(uint256 d=0; d<8;d++)
                           {
                             Global_Pool_1(addresstoid3[_add]);
                           }  
                           Global_Pool_4(_add);       
                        //  }else{
                        //     Global_Pool_two[_add].Withdrawable_Amount += 152 ether;
                        //     Global_Pool_two[_add].grandAmount = 0;
                        //     Global_Pool_two[_add].P1_Done = true;                   
                        //  }
                    }
                    _add = Global_Pool_three[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }
    uint256 private last_ref4 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray4;
    mapping(address => uint256 ) private userlastId4;
    mapping(uint256 => address ) private addresstoid4;
    uint256  [] private TotalUser4 ;
    uint256 private index4 =1;
    uint256 private Ids4 =1;
    mapping(address => uint256 []) private userids4;
    function Check_userids4(address a) public view returns(uint256 [] memory){
        return userids4[a];
    }
    function Global_Pool_4(uint256 _add_) private{       
            address useraddress = addresstoid4[_add_];
            userlastId4[useraddress] = Ids4;
            addresstoid4[Ids4] = useraddress;
            TotalUser4.push(Ids4);
            userids4[useraddress].push(Ids4);
            Ids4++;
        
        if(Global_Pool_four[last_ref4].Direct < 2){
        Global_Pool_four[userlastId4[useraddress]].upline = last_ref4;
        Global_Pool_four[last_ref4].Direct++;
        Global_DirectArray4[last_ref4].push(userlastId4[useraddress]);
        }else{
            last_ref4 = TotalUser4[index4];
            index4++;
            Global_Pool_four[userlastId4[useraddress]].upline = last_ref4;
            Global_Pool_four[last_ref4].Direct++;  
            Global_DirectArray[last_ref4].push(userlastId4[useraddress]);  
        }
        uint256 _add = Global_Pool_four[userlastId4[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_four[_add].P1 == false)
                 {
                   Global_Pool_four[_add].global_income +=24 ether ;
                   usdt.transfer(addresstoid4[_add], 24 ether);
                   
                     if(Global_Pool_four[_add].global_income == 720 ether)
                       {
                         Global_Pool_four[_add].P1 = true;
                       }
                       _add = Global_Pool_four[_add].upline;
                 }else
                 {
                    Global_Pool_four[_add].grandAmount += 24 ether;
                    if(Global_Pool_four[_add].grandAmount == 768 ether)
                    {
                           Global_Pool_four[_add].P1_1st = true;
                           Global_Pool_four[_add].P1_Done = true;
                           Global_Pool_four[_add].Withdrawable_Amount += 368 ether;
                           Global_Pool_four[_add].grandAmount = 0;
                           for(uint256 d=0; d<16;d++)
                           {
                             Global_Pool_1(addresstoid4[_add]);
                           }  
                           Global_Pool_5(_add);
                    }
                    _add = Global_Pool_four[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }

    uint256 private last_ref5 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray5;
    mapping(address => uint256 ) private userlastId5;
    mapping(uint256 => address ) private addresstoid5;
    uint256 [] private TotalUser5 ;
    uint256 private index5 =1;
    uint256 private Ids5 =1;
    mapping(address => uint256 []) private userids5;
    function Check_userids5(address a) public view returns(uint256 [] memory){
        return userids2[a];
    }


    function Global_Pool_5(uint256 _add_) private{       
            address useraddress = addresstoid4[_add_];
            userlastId5[useraddress] = Ids5;
            addresstoid5[Ids5] = useraddress;
            TotalUser5.push(Ids5);
            userids5[useraddress].push(Ids5);
            Ids5++;
        
        if(Global_Pool_five[last_ref5].Direct < 2){
        Global_Pool_five[userlastId5[useraddress]].upline = last_ref5;
        Global_Pool_five[last_ref5].Direct++;
        Global_DirectArray5[last_ref5].push(userlastId5[useraddress]);
        }else{
            last_ref5 = TotalUser5[index5];
            index5++;
            Global_Pool_five[userlastId5[useraddress]].upline = last_ref5;
            Global_Pool_five[last_ref5].Direct++;  
            Global_DirectArray[last_ref5].push(userlastId5[useraddress]);  
        }
        uint256 _add = Global_Pool_five[userlastId5[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_five[_add].P1 == false)
                 {
                   Global_Pool_five[_add].global_income +=48 ether ;
                   usdt.transfer(addresstoid2[_add], 48 ether);
                   
                     if(Global_Pool_five[_add].global_income == 1440 ether)
                       {
                         Global_Pool_five[_add].P1 = true;
                       }
                       _add = Global_Pool_five[_add].upline;
                 }else
                 {
                    Global_Pool_five[_add].grandAmount += 48 ether;
                    if(Global_Pool_five[_add].grandAmount == 1536 ether)
                    {
                           Global_Pool_five[_add].P1_1st = true;
                           Global_Pool_five[_add].P1_Done = true;
                           Global_Pool_five[_add].Withdrawable_Amount += 736 ether;
                           Global_Pool_five[_add].grandAmount = 0;
                           for(uint256 d=0; d<32;d++)
                           {
                             Global_Pool_1(addresstoid5[_add]);
                           }
                           Global_Pool_6(_add);  
                    }
                    _add = Global_Pool_five[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }
    uint256 private last_ref6 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray6;
    mapping(address => uint256 ) private userlastId6;
    mapping(uint256 => address ) private addresstoid6;
    uint256 [] private TotalUser6 ;
    uint256 private index6 =1;
    uint256 private Ids6 =1;
    mapping(address => uint256 []) private userids6;
    function Check_userids6(address a) public view returns(uint256 [] memory){
        return userids6[a];
    }


    function Global_Pool_6(uint256 _add_) private{       
            address useraddress = addresstoid5[_add_];
            userlastId6[useraddress] = Ids6;
            addresstoid6[Ids6] = useraddress;
            TotalUser6.push(Ids6);
            userids6[useraddress].push(Ids6);
            Ids6++;
        
        if(Global_Pool_six[last_ref6].Direct < 2){
        Global_Pool_six[userlastId6[useraddress]].upline = last_ref6;
        Global_Pool_six[last_ref6].Direct++;
        Global_DirectArray6[last_ref6].push(userlastId6[useraddress]);
        }else{
            last_ref6 = TotalUser6[index6];
            index6++;
            Global_Pool_six[userlastId6[useraddress]].upline = last_ref6;
            Global_Pool_six[last_ref6].Direct++;  
            Global_DirectArray[last_ref6].push(userlastId6[useraddress]);  
        }
        uint256 _add = Global_Pool_six[userlastId6[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_six[_add].P1 == false)
                 {
                   Global_Pool_six[_add].global_income +=96 ether ;
                   usdt.transfer(addresstoid2[_add], 96 ether);
                   
                     if(Global_Pool_six[_add].global_income == 2880 ether)
                       {
                         Global_Pool_six[_add].P1 = true;
                       }
                       _add = Global_Pool_six[_add].upline;
                 }else
                 {
                    Global_Pool_six[_add].grandAmount += 96 ether;
                    if(Global_Pool_six[_add].grandAmount == 3072 ether)
                    {
                           Global_Pool_six[_add].P1_1st = true;
                           Global_Pool_six[_add].P1_Done = true;
                           Global_Pool_six[_add].Withdrawable_Amount += 1472 ether;
                           Global_Pool_six[_add].grandAmount = 0;
                           for(uint256 d=0; d<64;d++)
                           {
                             Global_Pool_1(addresstoid6[_add]);
                           }
                           Global_Pool_7(_add);   
                    }
                    _add = Global_Pool_six[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }
    uint256 private last_ref7 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray7;
    mapping(address => uint256 ) private userlastId7;
    mapping(uint256 => address ) private addresstoid7;
    uint256 [] private TotalUser7 ;
    uint256 private index7 =1;
    uint256 private Ids7 =1;
    mapping(address => uint256 []) private userids7;
    function Check_userids7(address a) public view returns(uint256 [] memory){
        return userids7[a];
    }


    function Global_Pool_7(uint256 _add_) private{       
            address useraddress = addresstoid6[_add_];
            userlastId7[useraddress] = Ids7;
            addresstoid7[Ids7] = useraddress;
            TotalUser7.push(Ids7);
            userids7[useraddress].push(Ids7);
            Ids7++;
        
        if(Global_Pool_seven[last_ref7].Direct < 2){
        Global_Pool_seven[userlastId7[useraddress]].upline = last_ref7;
        Global_Pool_seven[last_ref7].Direct++;
        Global_DirectArray7[last_ref7].push(userlastId7[useraddress]);
        }else{
            last_ref7 = TotalUser7[index7];
            index7++;
            Global_Pool_seven[userlastId7[useraddress]].upline = last_ref7;
            Global_Pool_seven[last_ref7].Direct++;  
            Global_DirectArray[last_ref7].push(userlastId7[useraddress]);  
        }
        uint256 _add = Global_Pool_seven[userlastId7[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_seven[_add].P1 == false)
                 {
                   Global_Pool_seven[_add].global_income +=192 ether ;
                   usdt.transfer(addresstoid2[_add], 192 ether);
                   
                     if(Global_Pool_seven[_add].global_income == 5760 ether)
                       {
                         Global_Pool_seven[_add].P1 = true;
                       }
                       _add = Global_Pool_seven[_add].upline;
                 }else
                 {
                    Global_Pool_seven[_add].grandAmount += 192 ether;
                    if(Global_Pool_seven[_add].grandAmount == 6144 ether)
                    {
                           Global_Pool_seven[_add].P1_1st = true;
                           Global_Pool_seven[_add].P1_Done = true;
                           Global_Pool_seven[_add].Withdrawable_Amount += 2944 ether;
                           Global_Pool_seven[_add].grandAmount = 0;
                           for(uint256 d=0; d<128;d++)
                           {
                             Global_Pool_1(addresstoid7[_add]);
                           }
                           Global_Pool_8(_add);   
                    }
                    _add = Global_Pool_seven[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }


    uint256 private last_ref8 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray8;
    mapping(address => uint256 ) private userlastId8;
    mapping(uint256 => address ) private addresstoid8;
    uint256 [] private TotalUser8 ;
    uint256 private index8 =1;
    uint256 private Ids8 =1;
    mapping(address => uint256 []) private userids8;
    function Check_userids8(address a) public view returns(uint256 [] memory){
        return userids8[a];
    }


    function Global_Pool_8(uint256 _add_) private{       
            address useraddress = addresstoid7[_add_];
            userlastId8[useraddress] = Ids8;
            addresstoid8[Ids8] = useraddress;
            TotalUser8.push(Ids8);
            userids8[useraddress].push(Ids8);
            Ids8++;
        
        if(Global_Pool_eight[last_ref8].Direct < 2){
        Global_Pool_eight[userlastId8[useraddress]].upline = last_ref8;
        Global_Pool_eight[last_ref8].Direct++;
        Global_DirectArray8[last_ref8].push(userlastId8[useraddress]);
        }else{
            last_ref8 = TotalUser8[index8];
            index8++;
            Global_Pool_eight[userlastId8[useraddress]].upline = last_ref8;
            Global_Pool_eight[last_ref8].Direct++;  
            Global_DirectArray[last_ref8].push(userlastId8[useraddress]);  
        }
        uint256 _add = Global_Pool_eight[userlastId8[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_eight[_add].P1 == false)
                 {
                   Global_Pool_eight[_add].global_income +=384 ether ;
                   usdt.transfer(addresstoid2[_add], 384 ether);
                   
                     if(Global_Pool_eight[_add].global_income == 11520 ether)
                       {
                         Global_Pool_eight[_add].P1 = true;
                       }
                       _add = Global_Pool_eight[_add].upline;
                 }else
                 {
                    Global_Pool_eight[_add].grandAmount += 384 ether;
                    if(Global_Pool_eight[_add].grandAmount == 12288 ether)
                    {
                           Global_Pool_eight[_add].P1_1st = true;
                           Global_Pool_eight[_add].P1_Done = true;
                           Global_Pool_eight[_add].Withdrawable_Amount += 5888 ether;
                           Global_Pool_eight[_add].grandAmount = 0;
                           for(uint256 d=0; d<128;d++)
                           {
                             Global_Pool_1(addresstoid8[_add]);
                           }
                           Global_Pool_9(_add);   
                    }
                    _add = Global_Pool_eight[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }

    uint256 private last_ref9 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray9;
    mapping(address => uint256 ) private userlastId9;
    mapping(uint256 => address ) private addresstoid9;
    uint256 [] private TotalUser9 ;
    uint256 private index9 =1;
    uint256 private Ids9 =1;
    mapping(address => uint256 []) private userids9;
    function Check_userids9(address a) public view returns(uint256 [] memory){
        return userids9[a];
    }


    function Global_Pool_9(uint256 _add_) private{       
            address useraddress = addresstoid8[_add_];
            userlastId9[useraddress] = Ids9;
            addresstoid9[Ids9] = useraddress;
            TotalUser9.push(Ids9);
            userids9[useraddress].push(Ids9);
            Ids9++;
        
        if(Global_Pool_nine[last_ref9].Direct < 2){
        Global_Pool_nine[userlastId9[useraddress]].upline = last_ref9;
        Global_Pool_nine[last_ref9].Direct++;
        Global_DirectArray9[last_ref9].push(userlastId9[useraddress]);
        }else{
            last_ref9 = TotalUser9[index9];
            index9++;
            Global_Pool_nine[userlastId9[useraddress]].upline = last_ref9;
            Global_Pool_nine[last_ref9].Direct++;  
            Global_DirectArray[last_ref9].push(userlastId9[useraddress]);  
        }
        uint256 _add = Global_Pool_nine[userlastId9[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_nine[_add].P1 == false)
                 {
                   Global_Pool_nine[_add].global_income +=768 ether ;
                   usdt.transfer(addresstoid2[_add], 768 ether);
                   
                     if(Global_Pool_nine[_add].global_income == 23040 ether)
                       {
                         Global_Pool_nine[_add].P1 = true;
                       }
                       _add = Global_Pool_nine[_add].upline;
                 }else
                 {
                    Global_Pool_nine[_add].grandAmount += 768 ether;
                    if(Global_Pool_nine[_add].grandAmount == 24576 ether)
                    {
                           Global_Pool_nine[_add].P1_1st = true;
                           Global_Pool_nine[_add].P1_Done = true;
                           Global_Pool_nine[_add].Withdrawable_Amount += 11776 ether;
                           Global_Pool_nine[_add].grandAmount = 0;
                           for(uint256 d=0; d<512;d++)
                           {
                             Global_Pool_1(addresstoid9[_add]);
                           }
                           Global_Pool_10(_add);
                    }
                    _add = Global_Pool_nine[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }


    uint256 private last_ref10 =1;
    mapping(uint256 => uint256 []) private Global_DirectArray10;
    mapping(address => uint256 ) private userlastId10;
    mapping(uint256 => address ) private addresstoid10;
    uint256 [] private TotalUser10 ;
    uint256 private index10 =1;
    uint256 private Ids10 =1;
    mapping(address => uint256 []) private userids10;
    function Check_userids10(address a) public view returns(uint256 [] memory){
        return userids10[a];
    }


    function Global_Pool_10(uint256 _add_) private{       
            address useraddress = addresstoid10[_add_];
            userlastId10[useraddress] = Ids10;
            addresstoid10[Ids10] = useraddress;
            TotalUser10.push(Ids10);
            userids10[useraddress].push(Ids10);
            Ids10++;
        
        if(Global_Pool_Ten[last_ref10].Direct < 2){
        Global_Pool_Ten[userlastId10[useraddress]].upline = last_ref10;
        Global_Pool_Ten[last_ref10].Direct++;
        Global_DirectArray10[last_ref10].push(userlastId10[useraddress]);
        }else{
            last_ref10 = TotalUser10[index10];
            index10++;
            Global_Pool_Ten[userlastId10[useraddress]].upline = last_ref10;
            Global_Pool_Ten[last_ref10].Direct++;  
            Global_DirectArray[last_ref10].push(userlastId10[useraddress]);  
        }
        uint256 _add = Global_Pool_Ten[userlastId10[useraddress]].upline;

        for(uint256 t=0;t<5;t++)
        {      
            if(_add != 0 && _add != 1)
            {
                if(Global_Pool_Ten[_add].P1 == false)
                 {
                   Global_Pool_Ten[_add].global_income +=1536 ether ;
                   usdt.transfer(addresstoid2[_add], 1536 ether);
                   
                     if(Global_Pool_Ten[_add].global_income == 46080 ether)
                       {
                         Global_Pool_Ten[_add].P1 = true;
                       }
                       _add = Global_Pool_Ten[_add].upline;
                 }else
                 {
                    Global_Pool_Ten[_add].grandAmount += 1536 ether;
                    if(Global_Pool_Ten[_add].grandAmount == 49152 ether)
                    {
                           Global_Pool_Ten[_add].P1_1st = true;
                           Global_Pool_Ten[_add].P1_Done = true;
                           Global_Pool_Ten[_add].Withdrawable_Amount += 23552 ether;
                           Global_Pool_Ten[_add].grandAmount = 0;
                           for(uint256 d=0; d<1024;d++)
                           {
                             Global_Pool_1(addresstoid10[_add]);
                           } 
                    }
                    _add = Global_Pool_Ten[_add].upline;
                 }
            }else
            {
                break;
            }
        }
    }

    function _setUpline (address _addr, address  _upline) private {
        if(Referrals [_addr].upline == address(0) && _upline != _addr && _addr != owner && (Referrals[_upline].deposit_time > 0 || _upline == owner)) {
            Referrals[_addr].upline = _upline;
            Referrals[_upline].referrals++;
        }
    }
    function IsUpline( address _upline) public view returns(bool status){
        if(Referrals[msg.sender].upline == address(0) && _upline != msg.sender && msg.sender != owner && (Referrals[_upline].deposit_time > 0 || _upline == owner)) 
        {
            status = true;  
        }
        return status;
    }
    function ChakUpline( address _upline) public view returns(address add){
        return Referrals[_upline].upline;
    }
    function DirectArray_global(uint256 a) public view returns(uint256 [] memory){
        return Global_DirectArray[a];
    }
    function DirectArray(address a) public view returns(address [] memory){
        return _DirectArray[a];
    }
     function set_replace_Upline (address _addr, address  _upline,uint256 _positions) private {
        require(Position_status[_upline][_positions] == false,"position not free");
            ReplaceBy[_addr].upline = _upline;
            ReplaceBy[_addr].position = _positions ;
            Position_status[_upline][_positions] = true;
            if(_positions == 1){
            ReplaceBy[_upline].left_side = _addr;
            }else{
                ReplaceBy[_upline].right_side = _addr;
            } 
            
    }
      function Check_Placement( address _upline) public view returns(address add){
        return ReplaceBy[_upline].upline;
    }
    function levelincome(address currentReferrer , uint256 amo) private{
        // address  = a;
        address s;
        for (uint256 i = 0; i < 50; i++) 
        {
            s = ChakUpline(currentReferrer);
            if (currentReferrer == owner) 
            {
                user[currentReferrer].owner_levelROI +=amo;
                break;
            }
            if(Position_to_raffar[currentReferrer][s] == 1 )
            {
                currentReferrer = Check_Placement(currentReferrer);
                user[currentReferrer].levelROI_left_side +=amo; 
                ReplaceBy[currentReferrer].Total_levelROI_left_side += amo;
            }
            else{
                currentReferrer = Check_Placement(currentReferrer);
                user[currentReferrer].levelROI_right_side +=amo;
                ReplaceBy[currentReferrer].Total_levelROI_right_side += amo;
            }
        }
    }
    function SIGNUP(address _referral,uint256 _amount ,uint256 _position) external  nonReentrant{
        require(Referrals[msg.sender].upline == address(0), "already register");
        require(IsUpline(_referral) == true, "upline not found");
        require(_amount >= user[msg.sender].amount, "min 50");
        require(_amount % 50 ether ==0 , "Invalid amount");
        require(_position == 1 || _position == 2, "please enter 1 or 2");
        _setUpline(msg.sender,_referral);
        Referrals[msg.sender].deposit_time = uint40(block.timestamp);
        ReplaceBy[msg.sender].last_right =msg.sender;
        ReplaceBy[msg.sender].last_Left  = msg.sender;
        if(_position == 1)
            {
                    set_replace_Upline(msg.sender,ReplaceBy[_referral].last_Left,_position);
                    ReplaceBy[_referral].last_Left  = msg.sender;
                    ReplaceBy[ReplaceBy[_referral].last_Left].last_Left  = msg.sender;
                                       
            }
            else
            {
                    set_replace_Upline(msg.sender,ReplaceBy[_referral].last_right,_position);
                    ReplaceBy[_referral].last_right  = msg.sender;
                    ReplaceBy[ReplaceBy[_referral].last_right].last_right  = msg.sender;
                                        
            }
        usdt.transferFrom(msg.sender,address(this),_amount);
        uint256 a1 = _amount*5/100;
        uint256 a2 = _amount*1/100;
        
        usdt.transfer(Add1,a1);
        usdt.transfer(Add2,a2);        
        _amount = _amount.sub(10 ether);
        _DirectArray[_referral].push(msg.sender);
        TotalUser.push(msg.sender);
        user[msg.sender].amount = _amount;
        user[msg.sender].userIncome += _amount;
        user[msg.sender].time   = uint40(block.timestamp);
        user[msg.sender].DailyPercentage = 500000000000000000;
        user[msg.sender].TotalPercentage = 200;
        user[msg.sender].maxrewad  = _amount*200/100;
        user[msg.sender].capping  += _amount*400/100;  
        Position_to_raffar[msg.sender][_referral] = _position;
        levelincome(msg.sender,_amount); 
        Global_Pool_1(msg.sender);
    }
    function Activation(uint256 _amount) external nonReentrant {
        require(Referrals[msg.sender].upline != address(0), "please register");
        require(_amount >= user[msg.sender].amount, "min 50");
        require(_amount % 50 ether ==0 , "Invalid amount");
        

        usdt.transferFrom(msg.sender,address(this),_amount);
        uint256 a1 = _amount*5/100;
        uint256 a2 = _amount*1/100;
        
        usdt.transfer(Add1,a1);
        usdt.transfer(Add2,a2);
        _amount = _amount.sub(10 ether);
        user[msg.sender].amount =_amount;
        user[msg.sender].userIncome += _amount;
        user[msg.sender].time   = uint40(block.timestamp);
        user[msg.sender].DailyPercentage = 500000000000000000;
        user[msg.sender].TotalPercentage = 200;
        user[msg.sender].maxrewad  = _amount*200/100; 
        user[msg.sender].capping  = _amount*400/100;
        levelincome(msg.sender,_amount); 
        user[msg.sender].stop = true;
        Global_Pool_1(msg.sender);
    }
    function Matching_income() public nonReentrant {
        uint256 matchingamount;
        if ( user[msg.sender].levelROI_left_side> user[msg.sender].levelROI_right_side )
        {
            matchingamount = user[msg.sender].levelROI_right_side;
            user[msg.sender].levelROI_left_side = user[msg.sender].levelROI_left_side.sub(user[msg.sender].levelROI_right_side);
            user[msg.sender].levelROI_right_side=0;
        }else{
            matchingamount = user[msg.sender].levelROI_left_side;
            user[msg.sender].levelROI_right_side = user[msg.sender].levelROI_right_side.sub(user[msg.sender].levelROI_left_side);
            user[msg.sender].levelROI_left_side=0;
        }

        uint256 matching_reward = Check_Matching_Income(msg.sender);
        if(matching_reward >0)
        {
            users[msg.sender].withdrawreward += matching_reward;
            user[msg.sender].capping = user[msg.sender].capping.sub(matching_reward);
            usdt.transfer(msg.sender,matching_reward);
        }
        

        users[msg.sender].amount += matchingamount;
        users[msg.sender].time   = uint40(block.timestamp);
        users[msg.sender].DailyPercentage += (matchingamount*500000000000000000/100000000000000000000);
        users[msg.sender].maxrewad  += matchingamount;         

        // users
    }
    function Check_Matching_Income(address _add) public view returns(uint256){
        uint256 totaltime = (block.timestamp-users[_add].time)/(time);
        uint256 totalreward = (totaltime*users[_add].DailyPercentage);
        uint256 totalavalaiblereward =  totalreward-users[_add].withdrawreward;
        if(users[_add].withdrawreward+totalavalaiblereward > users[_add].maxrewad)
        {
            totalavalaiblereward = users[_add].maxrewad-users[_add].withdrawreward;
        }
        return totalavalaiblereward;
    }
    function Check_ROI_Income(address _add) public view returns(uint256){
        uint256 totalavalaiblereward;
        if(user[_add].stop == false){
        uint256 totaltime = (block.timestamp-user[_add].time)/(time);
        uint256 totalreward = ((user[_add].amount*user[_add].DailyPercentage/100)/1e18)*totaltime;
         totalavalaiblereward =  totalreward-user[_add].withdrawreward;
        if(user[_add].withdrawreward+totalavalaiblereward > user[_add].maxrewad)
        {
            totalavalaiblereward = user[_add].maxrewad.sub(user[_add].withdrawreward);
        }
        }else{
            totalavalaiblereward =0;
        }
        return totalavalaiblereward;
    }
      function WithdrawReward() external nonReentrant{
 
        uint256 reward = Check_ROI_Income(msg.sender);
        user[msg.sender].withdrawreward += reward;
        uint256 matching_reward = Check_Matching_Income(msg.sender);
        users[msg.sender].withdrawreward += matching_reward; 
        uint256 total_reward = reward+matching_reward;
        user[msg.sender].capping = user[msg.sender].capping.sub(total_reward);
        Referrals[msg.sender].totalearn += total_reward;
        require(total_reward >= 10 ether , "error"); 
        usdt.transfer(msg.sender,total_reward);        
    }
        function Change_Owner(address add) external onlyOwner
    {
        owner = add;
    }

    function OwnerClaim(address add) external onlyOwner
    {
        require(block.timestamp > user[add].time + 365 days,"error");
        uint256 matching_reward = Check_Matching_Income(add);
        uint256 reward = Check_ROI_Income(add);
        users[add].withdrawreward += matching_reward;
        user[add].withdrawreward += reward;
        
        for(uint256 i=0; i < userids[add].length;i++)
        {
            uint256 _add =userids[add][i];
            reward += Global_Pool_One[_add].Withdrawable_Amount;
            Global_Pool_One[_add].Withdrawable_Amount=0;
        }
        if(userids2[add].length >0){
        for(uint256 i=0; i < userids2[add].length;i++)
        {
            uint256 _add = userids2[add][i];
            reward += Global_Pool_two[_add].Withdrawable_Amount;
            Global_Pool_two[_add].Withdrawable_Amount=0;
        }
        }
        if(userids3[add].length >0){
        for(uint256 i=0; i < userids3[add].length;i++)
        {
            uint256 _add =userids3[add][i];
            reward += Global_Pool_three[_add].Withdrawable_Amount;
            Global_Pool_three[_add].Withdrawable_Amount=0;
        }
        }
        usdt.transfer(msg.sender,reward);
    }
}



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }  
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    } 
}