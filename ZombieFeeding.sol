// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ZombieFactory.sol";

// Interface of Crypto Kitties used to feed zombies
interface KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

/// @title ZombieFeeding
/// @author cristianrisueo
/// @notice This contract contains functions attached to the breeding of a zombie
contract ZombieFeeding is ZombieFactory {
    // Declaration of the interface of CryptoKitties
    KittyInterface kittyContract;

    /// @notice The sender must be owner of the zombie to call the function 
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    /// @notice Setter of the interface of CryptoKitties
    /// @param _address The address of the contract
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /// @notice This function updates the time until next feeding of a given zombie
    /// @param _zombie The zombie whose feedtime is going to be updated
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + timeNextFeeding);
    }

    /// @notice This function checks if is already the time until next feeding of a given zombie 
    /// @param _zombie The zombie whose feedtime is going to be checked
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    /// @notice Gets the param, and creates a new zombie with varieties depending on the specie 
    /// @param _zombieId The id of the zombie that's going to be feeded
    /// @param _targetDna The dna of the target that will become food 
    /// @param _species The specie of the target
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        // Links the zombie in the array to this variable to get its dna and checks if is ready
        Zombie storage myZombie = zombies[_zombieId];

        require(_isReady(myZombie), "You have to wait until the zombie is ready to eat again");
        
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        
        // If the _species parameter is a kitty sets the last dna digits to 99 
        if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        
        // Creates a new zombie and updates the feeding time of the given one
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    /// @notice Gets the dna of the cryptoKitty and calls to feed and multiply
    /// @param _zombieId The id of the zombie that's going to be feeded
    /// @param _kittyId The id of the kitty that's going to be the food
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}