pragma solidity ^0.5.0;


contract DutchAuction {

    uint256 public _initialPrice;
    uint256 public _biddingPeriod;
    uint256 public _offerPriceDecrement;
    uint256 public _initialBlockNumber;
    address public winner;
    uint256 public winningBid;
    uint256 public currentBid;

    event BidEvent(
        address from,
        uint amount
    );

    // Useful modifiers
    modifier biddingOpenOnly {
        require (biddingOpen());
        _;
    }

    modifier biddingClosedOnly {
        require (!biddingOpen());
        _;
    }

    // constructor
    constructor(uint256 initialPrice,
    uint256 biddingPeriod,
    uint256 offerPriceDecrement,
    bool testMode) public {


        _initialPrice = initialPrice;
        _biddingPeriod = biddingPeriod;
        _offerPriceDecrement = offerPriceDecrement;
        _initialBlockNumber = getBlockNumber();
        _testMode = testMode;
        _creator = msg.sender;

        //TODO: place your code here
    }

    // Return the current price of the listing.
    // This should return 0 if bidding is not open or the auction has been won.
    function currentPrice() public view returns(uint) {

        if (!biddingOpen()) {
            return 0;
        }
        return _initialPrice - ((getBlockNumber() - _initialBlockNumber) * _offerPriceDecrement);
    }

    // Return true if bidding is open.
    // If the auction has been won, should return false.
    function biddingOpen() public view returns(bool isOpen) {
        if (getWinningBidder() != address(0) || (getBlockNumber() - _initialBlockNumber) >=  _biddingPeriod) {
            return false;
        } else {
            return true;
        }
    }

    // Return the winning bidder, if the auction has been won.
    // Otherwise should return 0.
    function getWinningBidder() public view returns(address winningBidder) {
        return winner;
    }


    function bid() public payable biddingOpenOnly {
        require(msg.value >= currentPrice());
        msg.sender.transfer(msg.value - currentPrice());
        winner = msg.sender;
    }

    function getLastBid() public view returns (uint256) {
        return currentBid;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function finalize() public creatorOnly biddingClosedOnly {
        _creator.transfer(address(this).balance);
        selfdestruct(_creator);
    }

    // No need to change any code below here

    uint256 _testTime;
    bool _testMode = false;
    address payable _creator;

    modifier creatorOnly {
        require(msg.sender == _creator);
        _;
    }

    modifier testOnly {
        require(_testMode);
        _;
    }

    function overrideTime(uint time) public creatorOnly testOnly {
        _testTime = time;
    }

    function clearTime() public creatorOnly testOnly{
        _testTime = 0;
    }

    function getBlockNumber() internal view returns (uint) {
        if (_testTime != 0){
            return _testTime;
        }
        return block.number;
    }
}
