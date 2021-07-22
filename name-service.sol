pragma solidity >=0.5.0 < 0.6.0;

contract NameService {
    uint256 _reservePrice;

    struct CommitmentStruct {
        bytes32 commitment;
        uint256 block_number;
}

    mapping(bytes32 => address) names;
    mapping(bytes32 => bytes32) changedNames;
    mapping(address => CommitmentStruct) commitments;

    // constructor
    constructor(uint256 reservePrice) public {
        _reservePrice = reservePrice;
    }

    function transferTo(bytes32 name, address newOwner) public {
        require(names[name] == msg.sender);

        names[name] = newOwner;
    }

    function setValue(bytes32 name, bytes32 value) public {
        require(names[name] == msg.sender);

        changedNames[name] = value;
    }

    function getValue(bytes32 name) public view returns (bytes32) {
        return changedNames[name];
    }

    function commitToName(bytes32 commitment) public payable {
        require(msg.value == _reservePrice);
        require(commitments[msg.sender].commitment == 0);

        commitments[msg.sender].commitment = commitment;
        commitments[msg.sender].block_number = getBlockNumber();
    }

    function registerName(bytes32 nonce, bytes32 name, bytes32 value) public {
        require(makeCommitment(nonce, name, msg.sender) == commitments[msg.sender].commitment);
        require(getBlockNumber() >  commitments[msg.sender].block_number + 20);
        require(names[name] == address(0));

        names[name] = msg.sender;
        changedNames[name] = value;
    }

    function getOwner(bytes32 name) public view returns(address) {
        return names[name];
    }

    // Commitment utility
    function makeCommitment(bytes32 nonce, bytes32 name, address sender) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(nonce, name, sender));
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}
