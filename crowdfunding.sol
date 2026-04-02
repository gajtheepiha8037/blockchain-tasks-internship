// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {

    address public admin;
    uint public goal;
    uint public totalFunds;
    bool public goalReached;

    // Track contributions
    mapping(address => uint) public contributions;

    constructor(uint _goal) {
        admin = msg.sender; // person deploying contract
        goal = _goal; // funding goal in wei
    }

    // Function to contribute ETH
    function contribute() public payable {
        require(msg.value > 0, "You must send ETH");

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        // Check if goal reached
        if (totalFunds >= goal) {
            goalReached = true;
        }
    }

    // Admin withdraws funds if goal reached
    function withdrawFunds() public {
        require(msg.sender == admin, "Only admin can withdraw");
        require(goalReached, "Funding goal not reached");

        payable(admin).transfer(address(this).balance);
    }

    // Contributors request refund if goal NOT reached
    function requestRefund() public {
        require(!goalReached, "Goal was reached, no refunds");
        require(contributions[msg.sender] > 0, "No contribution found");

        uint amount = contributions[msg.sender];
        contributions[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }

}