// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/SafeMath.sol";

/// @title ZombieFactory
/// @author cristianrisueo
/// @notice This is the main contract of the zombies game
contract ZombieFactory is Ownable {
    // Use of the library SafeMath
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    // Base variables to create a zombie
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint timeNextFeeding = 1 days;

    // Struct of a zombie
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Array that holds zombie's structs
    Zombie[] public zombies;

    // Mappings that store data of zombies and its owner 
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerToZombieCount;

    // Event launched after the creation of a zombie
    event ZombieCreated(uint zombieId, string name, uint dna);

    /// @notice This function is used to crate a new zombie
    /// @param _name The name of the new zombie
    /// @param _dna The dna of the new zombie
    function _createZombie(string memory _name, uint _dna) internal {
        // Creates a new stuct and adds it to the array
        Zombie memory newZombie = Zombie(_name, _dna, 1, uint32(block.timestamp + timeNextFeeding), 0, 0);
        zombies.push(newZombie);

        // Updates the mappings and emit the event
        zombieToOwner[zombies.length] = msg.sender;
        ownerToZombieCount[msg.sender] = ownerToZombieCount[msg.sender].add(1);

        emit ZombieCreated(zombies.length, _name, _dna);
    }

    /// @notice This function is used to generate and return a random DNA
    /// @param _str String used to generate the random DNA chain
    /// @return uint The final random DNA chain shorted
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    /// @notice This function will be called by the end user to create a new zombie
    /// @param _name The name of the new zombie that will be created
    function createRandomZombie(string memory _name) public {
        // Requires that the user does not have any zombies
        require(ownerToZombieCount[msg.sender] == 0, "This is not a factory, you already have one!!!");

        // Calls the functions to create a new zombie        
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}