// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract XDBToken is ERC20 {
    constructor() ERC20("XDB", "XDB") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }
}
