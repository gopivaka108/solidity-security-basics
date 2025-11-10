// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Value Flow (Payable)
 * Concept: Introduces the 'payable' keyword to allow the
 * contract to receive ETH (msg.value) in a deposit function.
 */

struct User {
    uint256 balance;
    bool isRegistered;
}

contract ValueFlow {

    address public ownerAddress;

    constructor() {
        ownerAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Not an Owner");
        _;
    }

    mapping(address => User) public userData;

    function registerUser(address _userAddress) public onlyOwner {
        _updateUserData(_userAddress);
    }

    function _updateUserData(address _userAddress) internal {
        userData[_userAddress].balance = 0;
        userData[_userAddress].isRegistered = true;
    }

    function deposit() public payable {
        // Adds the sent ETH (msg.value) to the caller's balance
        userData[msg.sender].balance += msg.value;
    }
}
