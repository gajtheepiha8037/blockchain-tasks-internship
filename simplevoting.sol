// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleVoting {

    address public admin;

    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates;

    mapping(address => bool) public hasVoted;

    event VoteCast(address voter, uint candidateId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidates.push(Candidate(_name, 0));
    }

    function vote(uint _candidateId) public {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount += 1;

        emit VoteCast(msg.sender, _candidateId);
    }

    function getVotes(uint _candidateId) public view returns (uint) {
        require(_candidateId < candidates.length, "Invalid candidate");
        return candidates[_candidateId].voteCount;
    }
}