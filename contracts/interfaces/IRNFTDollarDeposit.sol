// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IRocketpool {
  function deposit() external payable;
}

interface IWETH {
  function withdraw(uint256 amount) external;
}

interface IRNFTDollarDeposit {
  // Events
  event StakedWEthAndReceivedRNFDollar(
    address indexed sender,
    uint256 indexed amountOut
  );
  event NewStablecoinAddressAdded(address stablecoinAddress);
  event StablecoinAddressRemoved(address stablecoinAddress);
  event WEthAddressChanged(address oldWEthAddress, address newWEthAddress);
  event REthAddressChanged(address oldREthAddress, address newREthAddress);
  event RocketPoolDepositAddressChanged(
    address oldRocketPoolDepositAddress,
    address newRocketPoolDepositAddress
  );

  /// @notice Sends stablecoin rNFTD to the sender, swaping stablecoin(USDC, DAI, USDT etc.) to WETH and then staking it in Rocket Pool.
  /// @dev First manually call Stablecoin contract "Approve" function.
  /// @param tokenIn: The address of the stablecoin contract like USDC, DAI, USDT etc.
  /// @param amountIn: The amount in the stablecoin(USDC, DAI, USDT etc.).
  /// @param decimalsOfInput: Decimal of the stablecoin(USDC, DAI, USDT etc.).
  function depositRPAndMintRNFTD(
    address tokenIn,
    uint256 amountIn,
    uint256 decimalsOfInput
  ) external returns (uint256 amountOut);

  /// @notice Allows the admin to add a new address for the stablecoin.
  /// @param stablecoinAddress: The stablecoin address.
  function addNewStablecoinAddress(address stablecoinAddress) external;

  /// @notice Allows the admin to remove a address for the stablecoin.
  /// @param stablecoinAddress: The stablecoin address.
  function removeStablecoinAddress(address stablecoinAddress) external;

  /// @notice Allows the admin to change the wEth address.
  /// @param newWEthAddress: The new wEth address.
  function setNewWEthAddress(address newWEthAddress) external;

  /// @notice Allows the admin to change the rEth address.
  /// @param newREthAddress: The new rEth address.
  function setNewREthAddress(address newREthAddress) external;

  /// @notice Allows the admin to change the rocketPoolDeposit address.
  /// @param newRocketPoolDepositAddress: The new rocket pool deposit address.
  function setNewRocketPoolDepositAddress(
    address newRocketPoolDepositAddress
  ) external;
}
