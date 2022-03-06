// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Earn-out clause as a smart contract
 * @dev Implements a escrow mechanism to execute a earn-out clause
 */

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol';

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/utils';

interface IaToken {
    function balanceOf(address _user) external view returns (uint256);
    function redeem(uint256 _amount) external;
}


interface IAaveLendingPool {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}


contract earnOutClause {


IERC20 public dai = IERC20(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD);
IaToken public aToken = IaToken(0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a);
IAaveLendingPool public aaveLendingPool = IAaveLendingPool(0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c);
    
address public arbiter;
address public beneficiary;
address public depositor;

uint public date;
uint public grossRevenue;
uint public percentage;
uint public amount;

bool public canWithdraw = false;

constructor(address _arbiter, address _beneficiary, uint _date, uint _percentage)  {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        date = _date;
        depositor = msg.sender;
        percentage = _percentage;
    }


function depositMoney (uint256 _amount) external {
        amount = _amount;
        require(dai.transferFrom(msg.sender, address(this), amount));
        aaveLendingPool.deposit(address(dai), _amount, 0);


    }

function oracle (uint _grossRevenue) external {
        require (msg.sender == arbiter);
        require (canWithdraw == false);

        grossRevenue = _grossRevenue;
        canWithdraw = true;
}

function withdrawMoney() external {

        require (msg.sender == beneficiary);
        require (canWithdraw == true); 

        uint amountToWithdraw = (grossRevenue).div(100).mul(percentage);


        aDai.approve(address(aaveLendingPool), type(uint).max);
        aaveLendingPool.withdraw(address(dai), amountToWithdraw, beneficiary);
        aaveLendingPool.withdraw(address(dai), type(uint).max, depositor);

        

    }
    
}
