// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WhitelistAccess {

    address public admin;

    // Mapping to store whitelist status
    mapping(address => bool) public whitelist;

    // Constructor sets deployer as admin
    constructor() {
        admin = msg.sender;
    }

    // Modifier to restrict functions to admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to allow only whitelisted users
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender] == true, "Not whitelisted");
        _;
    }

    // Admin adds address to whitelist
    function addToWhitelist(address _user) public onlyAdmin {
        whitelist[_user] = true;
    }

    // Admin removes address from whitelist
    function removeFromWhitelist(address _user) public onlyAdmin {
        whitelist[_user] = false;
    }

    // Restricted function (only whitelisted users can call)
    function restrictedFunction() public view onlyWhitelisted returns(string memory) {
        return "You are allowed to access this function!";
    }
}