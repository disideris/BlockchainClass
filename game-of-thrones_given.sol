pragma solidity ^0.5.0;

contract GameOfThrones {

  address payable public owner;
  address payable public king;
  uint public price;
  bytes32 public token;

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  constructor(string memory _token) public payable {
    owner = msg.sender;
    king = msg.sender;
    price = msg.value;
    token = keccak256(abi.encodePacked(_token));
  }

  function() external payable {
    require(msg.value > price, "Value should be bigger than price");
    require(msg.value - price <= 10, "Difference should be less than 10 wei");
    king.transfer(msg.value);
    king = msg.sender;
    price = msg.value;
  }

  function destroy() onlyOwner public {
      selfdestruct(owner);
  }
 }
