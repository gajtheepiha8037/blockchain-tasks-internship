// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {

    address[] public owners;
    mapping(address => bool) public isOwner;

    uint public requiredApprovals;

    struct Transaction {
        address to;
        uint value;
        bool executed;
        uint approvalCount;
    }

    Transaction[] public transactions;

    mapping(uint => mapping(address => bool)) public approvals;

    event Deposit(address indexed sender, uint amount);
    event SubmitTransaction(uint indexed txId, address indexed to, uint value);
    event ApproveTransaction(address indexed owner, uint indexed txId);
    event ExecuteTransaction(uint indexed txId);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "Transaction already executed");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approvals[_txId][msg.sender], "Already approved");
        _;
    }

    constructor(address[] memory _owners, uint _requiredApprovals) {

        require(_owners.length > 0, "Owners required");
        require(
            _requiredApprovals > 0 && _requiredApprovals <= _owners.length,
            "Invalid number of approvals"
        );

        for (uint i = 0; i < _owners.length; i++) {

            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredApprovals = _requiredApprovals;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint _value) public onlyOwner {

        uint txId = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                approvalCount: 0
            })
        );

        emit SubmitTransaction(txId, _to, _value);
    }

    function approveTransaction(uint _txId)
        public
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
        notApproved(_txId)
    {

        approvals[_txId][msg.sender] = true;

        transactions[_txId].approvalCount++;

        emit ApproveTransaction(msg.sender, _txId);
    }

    function executeTransaction(uint _txId)
        public
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {

        Transaction storage transaction = transactions[_txId];

        require(
            transaction.approvalCount >= requiredApprovals,
            "Not enough approvals"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}("");
        require(success, "Transaction failed");

        emit ExecuteTransaction(_txId);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }
}