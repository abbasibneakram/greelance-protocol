// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract TokenDistribution {
    address public admin;
    mapping(address => uint256) public userBalances;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    event TokensAllocated(address indexed user, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount);
    event RemainingTokensWithdrawn(uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    function allocateTokens(address user, uint256 amount) external onlyAdmin {
        require(amount > 0, "Amount must be greater than zero");

        userBalances[user] += amount;
        emit TokensAllocated(user, amount);
    }

    function allocateTokensMultiple(
        address[] calldata users,
        uint256[] calldata amounts
    ) external onlyAdmin {
        require(users.length == amounts.length, "Array lengths must match");

        for (uint256 i = 0; i < users.length; i++) {
            userBalances[users[i]] = amounts[i];
        }
    }

    function withdrawTokens(uint256 amount) external {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");

        userBalances[msg.sender] -= amount;
        //token.transfer(msg.sender, amount);

        emit TokensWithdrawn(msg.sender, amount);
    }

    function withdrawRemainingTokens() external onlyAdmin {
        uint256 remainingBalance = userBalances[address(this)];
        require(remainingBalance > 0, "No remaining tokens");
        //token.transfer(admin, remainingBalance);

        emit RemainingTokensWithdrawn(remainingBalance);
    }
}
