// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockedWallet {

    address public owner;
    uint public unlockTime;
    uint public balance;

    constructor(uint _lockTimeInSeconds) {
        owner = msg.sender;
        unlockTime = block.timestamp + _lockTimeInSeconds;
    }

    // Function to deposit ETH
    function deposit() public payable {
        require(msg.value > 0, "Send ETH to deposit");
        balance += msg.value;
    }

    // Function to withdraw ETH after unlock time
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(block.timestamp >= unlockTime, "Funds are still locked");
        require(balance > 0, "No funds available");

        uint amount = balance;
        balance = 0;

        payable(owner).transfer(amount);
    }

    // Function to check remaining lock time
    function getRemainingTime() public view returns (uint) {
        if(block.timestamp >= unlockTime){
            return 0;
        } else {
            return unlockTime - block.timestamp;
        }
    }
}