// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Reentrancy Attack & Fix
 * Concept: Demonstrates the flawed "Checks-Interaction-Effects" pattern
 * and the secure "Checks-Effects-Interaction" (CEI) pattern.
 */

struct User {
    uint256 balance;
    bool isRegistered;
}

contract ReentrancyDemo {

    address public ownerAddress;

    constructor() {
        ownerAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Not an Owner");
        _;
    }

    mapping(address => User) public userData;

    // --- Helper Functions ---

    function registerUser(address _userAddress) public onlyOwner {
        _updateUserData(_userAddress);
    }

    function _updateUserData(address _userAddress) internal {
        userData[_userAddress] = User(0, true); // Cleaner struct instantiation
    }

    // --- Value Flow Functions ---

    function deposit() public payable {
        // Only registered users can deposit
        require(userData[msg.sender].isRegistered, "User not registered");
        userData[msg.sender].balance += msg.value;
    }

    // --- 1. THE FLAW (VULNERABLE) ---
    // This function follows the Checks-Interaction-Effects pattern.
    // It is vulnerable to a reentrancy attack.
    function vulnerableWithdraw(uint256 _amount) public {
        // 1. CHECK
        require(userData[msg.sender].balance >= _amount, "Insufficient balance");

        // 2. INTERACTION (The Flaw)
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send ETH");

        // 3. EFFECT (Too Late)
        userData[msg.sender].balance -= _amount;
    }

    // --- 2. THE FIX (SECURE) ---
    // This function follows the Checks-Effects-Interaction (CEI) pattern.
    // It is secure against reentrancy.
    function secureWithdraw(uint256 _amount) public {
        // 1. CHECK
        require(userData[msg.sender].balance >= _amount, "Insufficient balance");

        // 2. EFFECT (Update State First)
        userData[msg.sender].balance -= _amount;

        // 3. INTERACTION (Send ETH Last)
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send ETH");
    }
}
