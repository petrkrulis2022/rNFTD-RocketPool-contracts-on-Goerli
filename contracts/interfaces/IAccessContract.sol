//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IAccessContract {
  // Event
  event NewAvailableContractAddressAdded(address newContractAddress);
  event AvailableContractAddressRemoved(address removedContractAddress);

  /// @notice Allows the ownable to add a new address for the availableContracts mapping.
  /// @param newContractAddress: The new contract address.
  function addNewAvailableContractAddress(address newContractAddress) external;

  /// @notice Allows the ownable to remove a address for the availableContracts mapping.
  /// @param removeContractAddress: The remove contract address.
  function removeAvailableContractAddress(
    address removeContractAddress
  ) external;
}
