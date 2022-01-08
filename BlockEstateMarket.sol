pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "./BlockEstateAuction.sol";

contract BlockEstateMarket is ERC721Full, Ownable {

    constructor() ERC721Full("BlockEstateMarket", "BEM") public {}

    // @TODO: Setup counter for token_ids
     using Counters for Counters.Counter;
     Counters.Counter token_ids;
    // @TODO: Set foundation_address to the contract deployer (msg.sender) and make it payable
    address payable foundation_address = msg.sender;
    // @TODO: Create a mapping of uint (token_id) => BlockEstateAuction
    mapping (uint => BlockEstateAuction) public auctions;

    // @TODO: Create a modifier called landRegistered that accepts a uint token_id, and checks if the token exists using the
    modifier landRegistered(uint token_id) {
        require(_exists(token_id),"Land Not Registered");
        _;
    }
    // ERC721 _exists function. If the token does not exist, return a message like "Land not registered!"

    function CreateAuction(uint token_id) public onlyOwner {
        // @TODO: Create a new BlockEstateAuction contract in the mapping relating to the token_id
        // Pass the foundation_address to the BlockEstateAuction constructor to set it as the beneficiary
        auctions[token_id] = new BlockEstateAuction(foundation_address);
    }
    struct Estate {
      //Implement car struct
      string lot_number;
      string street;
      string city;
      string state;
      string zip_code;
    }

    // Stores token_id => Car
    // Only permanent data that you would need to use in a smart contract later should be stored on-chain
    mapping(uint => Estate) public estate;

    function RegisterEstate(address foundation_address, string memory lot_number, string memory street, string memory city, string memory state, string memory zip_code,string memory uri) public {
        // @TODO: Increment the token_ids, and set a new id as token_ids.current
        token_ids.increment();
        uint token_id = token_ids.current();
        estate[token_id] = Estate(lot_number, street, city, state, zip_code);
        // @TODO: Mint a new token, setting the foundation as the owner, at the newly created id
        _mint(foundation_address, token_id);
        // @TODO: Use the _setTokenURI ERC721 function to set the token's URI by the id
        _setTokenURI(token_id, uri);
        // @TODO: Call the createAuction function and pass the token's id
        //CreateAuction(token_id);
    }
  
    function EndAuction(uint token_id) public onlyOwner landRegistered(token_id) {
        // @TODO: Fetch the BlockEstateAuction from the token_id
         BlockEstateAuction auction = auctions[token_id];
      
        // @TODO: Call the auction.end() function
        auction.auctionEnd();

        // @TODO: Call ERC721 safeTransferFrom, passing in owner() as the first param, auction.highestBidder() as the second, and token_id as the third
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
        // (Transfer from the owner of the token to the highest bidder of this auction, given this token_id)

    }

    function AuctionEnded(uint token_id) public view returns(bool) {
        // @TODO: Fetch the BlockEstateAuction relating to a given token_id, then return the value of auction.ended()
        BlockEstateAuction auction = auctions[token_id];
        return auction.ended();
    }

    function HighestBid(uint token_id) public view landRegistered(token_id) returns(uint) {
        // @TODO: Return the highest bid of the BlockEstateAuction relating to the given token_id
       BlockEstateAuction auction = auctions[token_id];
       return auction.highestBid();
    }

    function PendingReturn(uint token_id, address sender) public view landRegistered(token_id) returns(uint) {
        // @TODO: Return the auction.pendingReturn() value of a given address and token_id
        BlockEstateAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function Bid(uint token_id) public payable landRegistered(token_id) {
        // @TODO: Fetch the current BlockEstateAuction relating to a given token_id
        BlockEstateAuction auction = auctions[token_id];
        // @TODO: Call the auction.bid function using the auction.bid.value()() syntax
        // passing in msg.value in the first set of parenthesis to set the Ether being sent to the bid function,
        // and msg.sender in the second set of parenthesis to pass in the bidder parameter to the auction contract
        auction.bid.value(msg.value)(msg.sender);
    }

}
