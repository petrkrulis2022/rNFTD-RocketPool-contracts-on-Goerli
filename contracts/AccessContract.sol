//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IAccessContract} from "./interfaces/IAccessContract.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

// Custom errros
error AccessContract_ZeroAddress();
error AccessContract_NotHaveAccess(address sender);
error AccessContract_AlreadyAvailableContractAdded(address availableContract);

/// @notice Access Contract contract through which it provides access to certain functions.
contract AccessContract is Ownable2Step, IAccessContract {
  mapping(address => bool) public availableContracts;

  modifier onlyAvailableContract() {
    if (!availableContracts[msg.sender])
      revert AccessContract_NotHaveAccess(msg.sender);
    _;
  }

  modifier zeroAddress(address _address) {
    if (_address == address(0)) revert AccessContract_ZeroAddress();
    _;
  }

  /// @notice Allows the ownable to add a new address for the availableContracts mapping.
  /// @param newContractAddress: The new contract address.
  function addNewAvailableContractAddress(
    address newContractAddress
  ) external zeroAddress(newContractAddress) onlyOwner {
    if (availableContracts[newContractAddress])
      revert AccessContract_AlreadyAvailableContractAdded(newContractAddress);

    availableContracts[newContractAddress] = true;

    emit NewAvailableContractAddressAdded(newContractAddress);
  }

  /// @notice Allows the ownable to remove a address for the availableContracts mapping.
  /// @param removeContractAddress: The contract address.
  function removeAvailableContractAddress(
    address removeContractAddress
  ) external zeroAddress(removeContractAddress) onlyOwner {
    delete (availableContracts[removeContractAddress]);

    emit AvailableContractAddressRemoved(removeContractAddress);
  }
}
