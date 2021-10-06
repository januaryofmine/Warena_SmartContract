// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./MintableToken.sol";

contract Marketplace is Ownable, ReentrancyGuard {
    struct Item {
        address owner;
        uint256 price;
    }

    struct Fee {
        uint16 seller;
        uint16 buyer;
    }

    MintableToken public mintableToken;
    address public wareToken;
    Fee public defaultFees;
    uint256 minimumPrice;

    mapping(uint256 => Item) public items;

    event Listing(address indexed owner, uint256 indexed nftId, uint256 price);

    event Unlisting(address indexed owner, uint256 indexed nftId);

    event Purchase(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 indexed nftId,
        uint256 listingPrice,
        uint256 sellerAmount,
        uint256 buyerAmount
    );

    event PriceUpdated(
        address indexed owner,
        uint256 indexed nftId,
        uint256 oldPrice,
        uint256 newPrice
    );

    constructor(MintableToken _mintableToken, address _wareToken) {
        mintableToken = _mintableToken;
        wareToken = _wareToken;
        defaultFees = Fee(500, 500);
        minimumPrice = 0.001 ether;
    }

    function listing(uint256 _nftId, uint256 _amount) external {
        require(
            mintableToken.ownerOf(_nftId) == _msgSender(),
            "You are not the owner"
        );
        require(
            items[_nftId].owner == address(0),
            "Item has been listed already"
        );
        require(
            _amount >= minimumPrice,
            "Amount cannot be less than minimum price"
        );

        mintableToken.transferFrom(_msgSender(), address(this), _nftId);

        items[_nftId] = Item(_msgSender(), _amount);

        emit Listing(_msgSender(), _nftId, _amount);
    }

    function unlisting(uint256 _nftId) external {
        require(_msgSender() == items[_nftId].owner, "You are not the owner");

        delete items[_nftId];

        mintableToken.transferFrom(address(this), _msgSender(), _nftId);

        emit Unlisting(_msgSender(), _nftId);
    }

    function buy(uint256 _nftId) external {
        require(
            _msgSender() != items[_nftId].owner,
            "You cannot buy what you own"
        );
        require(
            items[_nftId].owner != address(0),
            "Item has not been listed currently"
        );

        address previousOwner = items[_nftId].owner;
        address newOwner = _msgSender();

        (uint256 sellerAmount, uint256 buyerAmount) = _trade(_nftId);

        emit Purchase(
            previousOwner,
            newOwner,
            _nftId,
            items[_nftId].price,
            sellerAmount,
            buyerAmount
        );
    }

    function _trade(uint256 _nftId)
        private
        returns (uint256 sellerAmount, uint256 buyerAmount)
    {
        uint16 sellerFee = defaultFees.seller;
        uint16 buyerFee = defaultFees.buyer;

        uint256 sellerFeeAmount = (items[_nftId].price * sellerFee) / 10000;
        uint256 buyerFeeAmount = (items[_nftId].price * buyerFee) / 10000;

        sellerAmount = items[_nftId].price - sellerFeeAmount;
        buyerAmount = items[_nftId].price + buyerFeeAmount;

        IERC20(wareToken).transferFrom(_msgSender(), owner(), sellerFeeAmount);
        IERC20(wareToken).transferFrom(_msgSender(), owner(), buyerFeeAmount);
        IERC20(wareToken).transferFrom(
            _msgSender(),
            items[_nftId].owner,
            sellerAmount
        );

        if (msg.value != 0) {
            payable(_msgSender()).transfer(msg.value);
        }

        mintableToken.transferFrom(address(this), _msgSender(), _nftId);

        delete items[_nftId];
    }

    function updatePrice(uint256 _nftId, uint256 _price) external {
        require(_msgSender() == items[_nftId].owner, "You are not the owner");

        uint256 oldPrice = items[_nftId].price;
        items[_nftId].price = _price;

        emit PriceUpdated(_msgSender(), _nftId, oldPrice, _price);
    }
}
