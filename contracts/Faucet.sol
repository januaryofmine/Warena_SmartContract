pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Faucet is Ownable {
    address private _renaToken;
    uint256 private _renaAmount;
    mapping(address => bool) private _renaClaimed;
    
    constructor(address renaToken, uint256 amount) {
        _renaToken = renaToken;
        _renaAmount = amount;
    }

    function claim() public {
        require(_renaClaimed[msg.sender] == false, "Already claimed");
        require(IERC20(_renaToken).balanceOf(address(this)) > _renaAmount, "Not enough amount");


        IERC20(_renaToken).transfer(msg.sender, _renaAmount);
        _renaClaimed[msg.sender] = true;
    }

    function transferOut(uint256 amount, address receiver) onlyOwner public {
        IERC20(_renaToken).transfer(receiver, amount);
    }
}