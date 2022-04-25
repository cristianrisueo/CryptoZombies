// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./zombiehelper.sol";
import "./OpenZeppelin/SafeMath.sol";

/// @title ZombieAttack
/// @author cristianrisueo
/// @notice This contract contains the data and logic related to the battle system
contract ZombieAttack is ZombieHelper {
    // Use of the library SafeMath
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    // Variable used to make the pseudorandomness
    uint randNonce = 0;
    uint attackVictoryProbability = 70;

    /// @notice This function is used to calculate the pseudorandom number
    /// @param _modulus the divisor to get the number
    /// @return uint The pseudorandom number
    function randMod(uint _modulus) internal returns(uint) {
        randNonce = randNonce.add(1);
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    }

    /// @notice This function is the attack system of the game
    /// @param _zombieId The ID of our zombie
    /// @param _targetId The ID of the food of our zombie
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        // Gets the zombies from the array and generates the pseudorandom number
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint rand = randMod(100);

        // If our zombie wins updates some stats and calls feedAndMultiply
        if (rand <= attackVictoryProbability) {
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            // If our zombie losses updates some stats and calls _triggerCoolDown
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = myZombie.winCount.add(1);
            _triggerCooldown(myZombie);
        }
    }
}