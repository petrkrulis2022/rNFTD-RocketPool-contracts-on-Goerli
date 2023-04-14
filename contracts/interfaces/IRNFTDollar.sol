//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IRNFTDollar {
  /// @notice Mint new rNFTD tokens.
  /// @param to: The address to which they will be sent.
  /// @param amount: The amount to be minted.
  /// @param decimalsOfInput: Decimal of the stablecoin(USDC, DAI, USDT etc.).
  function mint(address to, uint256 amount, uint256 decimalsOfInput) external;
}
