// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./zombieattack.sol";
import "./OpenZeppelin/Erc721.sol";
import "./OpenZeppelin/SafeMath.sol";

/// @title ZombieOwnership
/// @author cristianrisueo
/// @notice This contract contains some logic from the ERC721 token but includes 
/// other logic related to the rules of the game
contract ZombieOwnership is ZombieAttack, ERC721 {
  // Use of the library SafeMath
  using SafeMath for uint256;

  // People approved to transfer a given Zombie
  mapping (uint => address) zombieApprovals;

  /// @notice This function returns the number of zombies owned by the address
  /// @param _owner The address of the owner of the zombies
  function balanceOf(address _owner) external view override returns (uint256) {
    return ownerToZombieCount[_owner];
  }

  /// @notice This function returns the address of the owner of a zombie given its ID
  /// @param _tokenId The ID of the zombie we want to know the owner
  function ownerOf(uint256 _tokenId) external view override returns (address) {
    return zombieToOwner[_tokenId];
  }
  
  /// @notice The internal function called when we want to transfer a zombie
  /// @param _from The address of the owner of the zombie we want to transfer
  /// @param _to The address of who we want to transfer the zombie to
  /// @param _tokenId The ID of the zombie we want to transfer
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // Updates the mappings and emits the event
    ownerToZombieCount[_to] = ownerToZombieCount[_to].add(1);
    ownerToZombieCount[_from] = ownerToZombieCount[_from].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  /// @notice This function is used to transfer a zombie from one owner to another
  /// @param _from The address of the owner of the zombie we want to transfer
  /// @param _to The address of who we want to transfer the zombie to
  /// @param _tokenId The ID of the zombie we want to transfer
  function transferFrom(address _from, address _to, uint256 _tokenId) external override payable {
    // Require that the sender is the owner of the zombie or is approved to transfer it
    require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) external override payable onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }
}
