// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Secure Refactoring (Visibility)
 * Concept: Moves core logic into a clean 'internal' helper function
 * to separate concerns and improve security.
 */
contract Refactoring {

    address public ownerAddress;

    constructor() {
        ownerAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Not an Owner");
        _;
    }

    struct User {
        uint256 balance;
        bool isRegistered;
    }

    mapping(address => User) public userData;

    // Public function is the "gate"
    function registerUser(address _userAddress) public onlyOwner {
        _updateUserData(_userAddress); // Calls the helper
    }

    // Internal function does the "work"
    // It's hidden from the public but visible to the contract
    function _updateUserData(address _userAddress) internal {
        userData[_userAddress].balance = 0;
        userData[_userAddress].isRegistered = true;
    }
}
