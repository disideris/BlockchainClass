pragma solidity ^0.5.0;

contract ERC20 {
    address payable public owner;
    event Transfer(address indexed from, address indexed to, uint256 value);

    string  coinName;
string  coinSymbol;

mapping(address => uint256) balances;

using SafeMath for uint256;

uint256 totalSupply_;

    constructor (string memory name, string memory symbol) public {
        owner = msg.sender;
        coinName = name;
coinSymbol = symbol;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Total number of tokens in existence.
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_ - balances[address(0)];
    }

    /**
     * Gets the balance of the specified address.
     */
    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    /**
     * Transfer token to a specified address.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender]);
        balances[msg.sender] =balances[msg.sender].safeSub(value);
        balances[to] = balances[to].safeAdd(value);
        emit Transfer(msg.sender, to, value);

        return true;
    }

    /**
     * Function to mint tokens
     */
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        require(to != address(0), "ERC20: mint to the zero address");
        totalSupply_ = totalSupply_.safeAdd(value);
        balances[to] = balances[to].safeAdd(value);
        emit Transfer(address(0), to, value);
        return true;
    }

    /**
     * The name of the token.
     */
    function name() public view returns (string memory) {
        return coinName;
    }

    /**
     * The symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return coinSymbol;
    }
}
library SafeMath {

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
