// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

/// @title ZombieHelper
/// @author cristianrisueo
/// @notice This contract contains secondary functions related to levelup and army of zombies
contract ZombieHelper is ZombieFeeding {
    // Price to pay to level up the zombie
    uint levelUpFee = 0.001 ether;

    /// @notice This modifier is used to check if the level of the zombie is the required
    /// @param _level The required level the zombie must have
    /// @param _zombieId The ID of the zombie we are validating
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    /// @notice This function does a withdraw of founds to the wallet of the owner of contract
    function withdraw() external onlyOwner {
        address payable _owner = payable(address(uint160(owner())));
        _owner.transfer(address(this).balance);
    }

    /// @notice Setter of the variable levelUpFee
    /// @param _fee The new fee
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    /// @notice This function requires that the user pays the fee and then increases 
    /// the level of the zombie
    /// @param _zombieId The ID of the zombie we want to level up
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    /// @notice This function changes the name of a given zombie if passes the validations
    /// @param _zombieId The ID of the zombie we want to change its name
    /// @param _newName The new name we want to give to the zombie
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    /// @notice This function changes the DNA of a given zombie if passes the validations
    /// @param _zombieId The ID of the zombie we want to change its name
    /// @param _newDna The new DNA we want to give to the zombie
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    /// @notice This function gets a given address, extracts its zombies and adds it to a new 
    /// array. This is done to create an army of zombies in the battle system
    /// @param _owner The address of the owner of zombies 
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        // Creates a new array of the fixed size of owner counter of zombies
        uint[] memory result = new uint[](ownerToZombieCount[_owner]);
        uint counter = 0;
        
        // Loops the array just created and for every zombie the owner has adds it 
        for(uint i = 0; i < result.length; i++) {
            if(zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}
