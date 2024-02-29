// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Greelance is ERC20 {
    constructor() ERC20("Greelance", "GRL") {
        _mint(msg.sender, 2000000000 * 10 ** decimals());
    }
}
