# solidity-security-basics
# Solidity Security

## Core Concepts

* **Access Control:** `onlyOwner` modifier set via `constructor`.
* **Data Structures:** `struct` and `mapping` for user data.
* **Visibility:** Using `internal` for helper functions.
* **Value Flow:** `payable` functions and `msg.value` to handle deposits.

---

## Vulnerability Analysis: Reentrancy

Demonstrates the fix for a reentrancy attack by reordering operations to the **Checks-Effects-Interaction** pattern.

### ❌ Vulnerable (Checks-Interaction-Effects)

This pattern is flawed because it makes an external call (the Interaction) *before* updating its own state (the Effect).

```solidity
function vulnerableWithdraw(uint256 _amount) public {
    // 1. CHECK
    require(userData[msg.sender].balance >= _amount);

    // 2. INTERACTION (THE FLAW)
    (bool s, ) = msg.sender.call{value: _amount}("");
    require(s);

    // 3. EFFECT (Too Late)
    userData[msg.sender].balance -= _amount;
}
```

✅ Secure (Checks-Effects-Interaction)
This is the secure pattern. The state (Effect) is updated first, which prevents a re-entrant call from passing the initial Check.

```solidity
function secureWithdraw(uint256 _amount) public {
    // 1. CHECK
    require(userData[msg.sender].balance >= _amount);

    // 2. EFFECT (Update State First)
    userData[msg.sender].balance -= _amount;

    // 3. INTERACTION (Send ETH Last)
    (bool s, ) = msg.sender.call{value: _amount}("");
    require(s, "Failed to send ETH");
}
```
