// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract XDBFarm {
using SafeMath for uint256;
using SafeERC20 for IERC20;IERC20 public xdb;
IERC20 public usdc;
address public owner;
uint256 public rewardsPerBlock;
uint256 public lastUpdateBlock;
uint256 public accRewardsPerShare;

struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
}
mapping(address => UserInfo) public userInfo;

constructor(IERC20 _xdb, IERC20 _usdc, uint256 _rewardsPerBlock) {
    xdb = _xdb;
    usdc = _usdc;
    rewardsPerBlock = _rewardsPerBlock;
    owner = msg.sender;
    lastUpdateBlock = block.number;
}

function updatePool() public {
    if (block.number <= lastUpdateBlock) {
        return;
    }

    uint256 lpSupply = usdc.balanceOf(address(this));
    if (lpSupply == 0) {
        lastUpdateBlock = block.number;
        return;
    }

    uint256 blocks = block.number.sub(lastUpdateBlock);
    uint256 rewards = blocks.mul(rewardsPerBlock);
    accRewardsPerShare = accRewardsPerShare.add(rewards.mul(1e12).div(lpSupply));
    lastUpdateBlock = block.number;
}

function deposit(uint256 amount) public {
    updatePool();
    UserInfo storage user = userInfo[msg.sender];
    usdc.safeTransferFrom(msg.sender, address(this), amount);
    user.amount = user.amount.add(amount);
    user.rewardDebt = user.amount.mul(accRewardsPerShare).div(1e12);
}

function withdraw(uint256 amount) public {
    updatePool();
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount >= amount, "insufficient balance");
    usdc.safeTransfer(msg.sender, amount);
    user.amount = user.amount.sub(amount);
    user.rewardDebt = user.amount.mul(accRewardsPerShare).div(1e12);
}

function claim() public {
    updatePool();
    UserInfo storage user = userInfo[msg.sender];
    uint256 rewards = user.amount.mul(accRewardsPerShare).div(1e12).sub(user.rewardDebt);
    xdb.safeTransfer(msg.sender, rewards);
    user.rewardDebt = user.amount.mul(accRewardsPerShare).div(1e12);
}

function setRewardsPerBlock(uint256 _rewardsPerBlock) public {
    require(msg.sender == owner, "not owner");
    updatePool();
    rewardsPerBlock = _rewardsPerBlock;
}
}
