//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IRNFTDollar} from "./interfaces/IRNFTDollar.sol";
import {AccessContract} from "./AccessContract.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @author Georgi Karagyozov
/// @notice Stablecoin rNFTD contract, which rNFTD tokens are minted at 1 to 1 ratio when someone deposits the same value in the form of stablecoin like (USDC, DAI, USDT etc.)
contract RNFTDollar is IRNFTDollar, ERC20Burnable, AccessContract {
  constructor() ERC20("rNFT Dollar", "rNFTD") {}

  /// @notice Mint new rNFTD tokens.
  /// @param to: The address to which they will be sent.
  /// @param amount: The amount to be minted.
  /// @param decimalsOfInput: Decimal of the stablecoin(USDC, DAI, USDT etc.).
  function mint(
    address to,
    uint256 amount,
    uint256 decimalsOfInput
  ) external onlyAvailableContract {
    _mint(to, amount * 10 ** (18 - decimalsOfInput));
  }
}
