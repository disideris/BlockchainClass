pragma solidity ^0.5.0;

contract VickreyAuction {

    address payable public auctioneer;

    uint256 public _reservePrice;
    uint256 public _commitTimePeriod;
    uint256 public _revealTimePeriod;
    uint256 public _bidDepositAmount;

    uint256 public _bidCommitmentDeadline;
    uint256 public _bidReavealingDeadline;

    uint256 public firstBlock;

    address payable public _highestBidder;
    uint256 public _highestBid;
    uint256 public _secondHighestBid;

    mapping(address => bytes32) bidHashes;
    mapping(address => bool) revealed;
    mapping(address => uint256) balances;

    // constructor
    constructor (uint256 reservePrice,
                 uint256 commitTimePeriod, uint256 revealTimePeriod,
                 uint256 bidDepositAmount, bool testMode) public {

        _reservePrice = reservePrice;
        _commitTimePeriod = commitTimePeriod;
        _revealTimePeriod = revealTimePeriod;
        _bidDepositAmount = bidDepositAmount;
        _testMode = testMode;
        _creator = msg.sender;

        firstBlock = getBlockNumber();


        _bidCommitmentDeadline = firstBlock + _commitTimePeriod;
        _bidReavealingDeadline = _bidCommitmentDeadline + revealTimePeriod;


        auctioneer = msg.sender;

        _highestBidder = auctioneer;
        _highestBid = reservePrice;
        _secondHighestBid = reservePrice;

    }

    // Record the player's bid commitment
    // Make sure at least _bidDepositAmount is provided
    // Only allow commitments before the _bidCommitmentDeadline
    function commitBid(bytes32 bidCommitment) public payable returns(bool) {
        require(getBlockNumber() < _bidCommitmentDeadline);
        require(msg.value == _bidDepositAmount);
        require(msg.sender != auctioneer);

        bidHashes[msg.sender] = bidCommitment;
        return true;
    }


    // Check that the bid (msg.value) matches the commitment
    // Ignore the bid if it is less than the reserve price
    // Update the highest price, second highest price, highest bidder
    // If the second highest bidder is replaced, send them a refund
    function revealBid(bytes32 nonce) public payable returns(address highestBidder) {
        require(getBlockNumber() >= _bidCommitmentDeadline && getBlockNumber() < _bidReavealingDeadline);
        require(bidHashes[msg.sender] == makeCommitment(nonce, msg.value));
        require(msg.value > _reservePrice);
        require(!revealed[msg.sender]);

        revealed[msg.sender] = true;
        balances[msg.sender] += msg.value;

        if (msg.value > _highestBid) {
            if (_highestBidder != auctioneer) {
             _highestBidder.transfer(balances[_highestBidder] + _bidDepositAmount);
            }
            _secondHighestBid = _highestBid;
            _highestBid = msg.value;
            _highestBidder = msg.sender;
        } else {
            if (msg.value > _secondHighestBid) {
            _secondHighestBid = msg.value;
            }
            msg.sender.transfer(balances[msg.sender] + _bidDepositAmount);
       }

       return _highestBidder;
    }

    // Handle the end of the auction
    // Refund the difference between the first price and second price
    function finalize() public creatorOnly {
        require(getBlockNumber() >= _bidReavealingDeadline);
        require(revealed[_highestBidder]);

        _highestBidder.transfer(_highestBid - _secondHighestBid + _bidDepositAmount);
    }

    // Commitment utility
    function makeCommitment(bytes32 nonce, uint256 bidValue) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(nonce, bidValue));
    }

    // Return the current highest bidder
    function getHighestBidder() public view returns (address){
      return _highestBidder;
    }

    // Return the current highest bid
    function getHighestBid() public view returns (uint256){
      return _highestBid;
    }

    // Return the current second highest bid
    function getSecondHighestBid() public view returns (uint256){
      return _secondHighestBid;
    }

    // Get bidder's commitment
    function getCommitment(address bidder) public view returns (bytes32) {
        return bidHashes[bidder];
    }

    // No need to change any code below here

    bool _testMode;
    uint256 public _testTime;
    address _creator;

    modifier testOnly {
      require(_testMode);
      _;
    }

    modifier creatorOnly {
      require(msg.sender == _creator);
      _;
    }

    function overrideTime(uint256 time) public creatorOnly testOnly {
        _testTime = time;
    }

    function getBlockNumber() public view returns (uint256) {
        if (_testMode) return _testTime;
        return block.number;
    }
}
