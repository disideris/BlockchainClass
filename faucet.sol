pragma solidity >=0.5.0 < 0.6.0;


contract Faucet  {
    
    address payable public owner;

    event Withdrawal(
        address to,
        uint amount
    );
    
    event Deposit(
        address from,
        uint amount
    );
    
    modifier onlyOwner {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }
    
    constructor () public {
        owner = msg.sender;
    }
    

	function withdraw(uint withdrawAmount) public {
		require(withdrawAmount <= 100 wei);
		require(address(this).balance >= withdrawAmount, "Insufficient balance in faucet for withdrawal request");
		msg.sender.transfer(withdrawAmount);
		emit Withdrawal(msg.sender, withdrawAmount);
	}
	// Accept any incoming amount
	function () external payable {
		emit Deposit(msg.sender, msg.value);
	}
	
	function destroy() public onlyOwner{
       selfdestruct(owner); 
    }
}