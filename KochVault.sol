// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KOCHToken is ERC20, Ownable {
    address private feeWallet = 0x5929b4fD1b23f361c2aBf6389b07Babf2F9a908c;
    uint256 private feePercentage = 5;
    uint256 private maxSupply = 200;

    constructor() ERC20("KOCH", "$KOCH") {
        _mint(msg.sender, 0);
    }

    function excludeFee(address wallet) external onlyOwner {
        feeWallet = wallet;
    }

    function mint() payable external {
        require(msg.value > 0, "Amount must be greater than zero");
        require(totalSupply() + 10 <= maxSupply, "Max supply reached");

        uint256 amount = (msg.value * 10) / 0.001 ether;

        require(totalSupply() + amount <= maxSupply, "Max supply reached");

        _mint(msg.sender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount) internal override {
        uint256 feeAmount = (amount * feePercentage) / 100;
        uint256 transferAmount = amount - feeAmount;

        require(amount > 0, "Transfer amount must be greater than zero");
        require(transferAmount > 0, "Transfer amount after fee deduction must be greater than zero");

        if (feeAmount > 0 && sender != feeWallet) {
            _transfer(sender, feeWallet, feeAmount);
        }

        super._transfer(sender, recipient, transferAmount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount) public override returns (bool) {
            
        uint256 feeAmount = (amount * feePercentage) / 100;
        uint256 transferAmount = amount - feeAmount;

        require(amount > 0, "Transfer amount must be greater than zero");
        require(transferAmount > 0, "Transfer amount after fee deduction must be greater than zero");

        if (feeAmount > 0 && sender != feeWallet) {
            _transfer(sender, feeWallet, feeAmount);
        }

        super.transferFrom(sender, recipient, transferAmount);

        return true;
    }
}
