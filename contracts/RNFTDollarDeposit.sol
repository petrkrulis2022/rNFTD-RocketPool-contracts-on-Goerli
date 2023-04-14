//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IRNFTDollar} from "./interfaces/IRNFTDollar.sol";
import {IRNFTDollarDeposit, IRocketpool, IWETH} from "./interfaces/IRNFTDollarDeposit.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

// Custom errors
error RNFTDollarDeposit_ZeroAddress();
error RNFTDollarDeposit_NoRETHWasMinted();
error RNFTDollarDeposit_InvalidDepositAmount();
error RNFTDollarDeposit_NotAdminRole();
error RNFTDollarDeposit_AlreadyStablecoinAdded(address stablecoin);
error RNFTDollarDeposit_NotAvailableStablecoin(address stablecoin);

/// @author Georgi Karagyozov
contract RNFTDollarDeposit is AccessControl, IRNFTDollarDeposit {
  address public wEth;
  address public rEth;
  address public rocketPoolDeposit;

  uint24 public constant POOL_FEE = 3000;

  address public immutable rnftd;

  ISwapRouter public immutable swapRouter;

  mapping(address => uint256) public balances;
  mapping(address => bool) public availableStablecoins;

  modifier hasAdminRole() {
    if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender))
      revert RNFTDollarDeposit_NotAdminRole();
    _;
  }

  modifier zeroAddress(address _address) {
    if (_address == address(0)) revert RNFTDollarDeposit_ZeroAddress();
    _;
  }

  constructor(address _rnftd) zeroAddress(_rnftd) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

    wEth = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    rEth = 0x178E141a0E3b34152f73Ff610437A7bf9B83267A;
    rocketPoolDeposit = 0x2cac916b2A963Bf162f076C0a8a4a8200BCFBfb4;

    rnftd = _rnftd;
    swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    availableStablecoins[0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844] = true; //DAI address
    availableStablecoins[0xe583769738b6dd4E7CAF8451050d1948BE717679] = true; //USDT address
    availableStablecoins[0x07865c6E87B9F70255377e024ace6630C1Eaa37F] = true; //USDC address
  }

  /// @notice swapExactInputSingle swaps a fixed amount of stablecoin for a maximum possible amount of WETH
  /// using the stablecoin/WETH 0.3% pool by calling `exactInputSingle` in the swap router.
  /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its stablecoin for this function to succeed.
  /// @param amountIn The exact amount of stablecoin that will be swapped for WETH.
  /// @param tokenIn: Stablecoin's address, which we will swap fro WETH.
  /// @return amountOut The amount of WETH received.
  function swapExactInputSingle(
    uint256 amountIn,
    address tokenIn
  ) private returns (uint256 amountOut) {
    // Transfer the specified amount of stablecoin to this contract
    TransferHelper.safeTransferFrom(
      tokenIn,
      msg.sender,
      address(this),
      amountIn
    );

    // Approve the router to spend stablecoin
    TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

    // Swaps stablecoin for WETH
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams({
        tokenIn: tokenIn,
        tokenOut: wEth,
        fee: POOL_FEE,
        recipient: address(this),
        deadline: block.timestamp,
        amountIn: amountIn,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0
      });

    // The amount of WETH received upon swap
    amountOut = swapRouter.exactInputSingle(params);
  }

  /// @notice Sends stablecoin rNFTD to the sender, swaping stablecoin(USDC, DAI, USDT etc.) to WETH and then staking it in Rocket Pool.
  /// @dev First manually call Stablecoin contract "Approve" function.
  /// @param tokenIn: The address of the stablecoin contract like USDC, DAI, USDT etc.
  /// @param amountIn: The amount in the stablecoin(USDC, DAI, USDT etc.).
  /// @param decimalsOfInput: Decimal of the stablecoin(USDC, DAI, USDT etc.).
  function depositRPAndMintRNFTD(
    address tokenIn,
    uint256 amountIn,
    uint256 decimalsOfInput
  ) external returns (uint256 amountOut) {
    if (amountIn <= 0) revert RNFTDollarDeposit_InvalidDepositAmount();
    if (!availableStablecoins[tokenIn])
      revert RNFTDollarDeposit_NotAvailableStablecoin(tokenIn);

    // Swaps stablecoin for WETH
    amountOut = swapExactInputSingle(amountIn, tokenIn);

    // Mints the native rNFTD token at 1 to 1 ratio and send to the sender
    IRNFTDollar(rnftd).mint(msg.sender, amountIn, decimalsOfInput);

    IWETH(wEth).withdraw(amountOut);

    // Queries the senders RETH balance prior to deposit
    uint256 rethBalance1 = IERC20(rEth).balanceOf(address(this));
    // Deposits the ETH and gets RETH back
    IRocketpool(rocketPoolDeposit).deposit{value: amountOut}();
    // Queries the senders RETH balance after the deposit
    uint256 rethBalance2 = IERC20(rEth).balanceOf(address(this));
    if (rethBalance2 < rethBalance1) revert RNFTDollarDeposit_NoRETHWasMinted();
    uint256 rethMinted = rethBalance2 - rethBalance1;

    // Stores the amount of reth received by the user in a mapping
    balances[msg.sender] += rethMinted;

    emit StakedWEthAndReceivedRNFDollar(msg.sender, amountOut);
  }

  /// @notice Allows the admin to add a new address for the stablecoin.
  /// @param stablecoinAddress: The stablecoin address.
  function addNewStablecoinAddress(
    address stablecoinAddress
  ) external zeroAddress(stablecoinAddress) hasAdminRole {
    if (availableStablecoins[stablecoinAddress])
      revert RNFTDollarDeposit_AlreadyStablecoinAdded(stablecoinAddress);

    availableStablecoins[stablecoinAddress] = true;

    emit NewStablecoinAddressAdded(stablecoinAddress);
  }

  /// @notice Allows the admin to remove a address for the stablecoin.
  /// @param stablecoinAddress: The stablecoin address.
  function removeStablecoinAddress(
    address stablecoinAddress
  ) external zeroAddress(stablecoinAddress) hasAdminRole {
    delete (availableStablecoins[stablecoinAddress]);

    emit StablecoinAddressRemoved(stablecoinAddress);
  }

  /// @notice Allows the admin to change the wEth address.
  /// @param newWEthAddress: The new wEth address.
  function setNewWEthAddress(
    address newWEthAddress
  ) external zeroAddress(newWEthAddress) hasAdminRole {
    emit WEthAddressChanged(wEth, newWEthAddress);
    wEth = newWEthAddress;
  }

  /// @notice Allows the admin to change the rEth address.
  /// @param newREthAddress: The new rEth address.
  function setNewREthAddress(
    address newREthAddress
  ) external zeroAddress(newREthAddress) hasAdminRole {
    emit REthAddressChanged(rEth, newREthAddress);
    rEth = newREthAddress;
  }

  /// @notice Allows the admin to change the rocketPoolDeposit address.
  /// @param newRocketPoolDepositAddress: The new rocket pool deposit address.
  function setNewRocketPoolDepositAddress(
    address newRocketPoolDepositAddress
  ) external zeroAddress(newRocketPoolDepositAddress) hasAdminRole {
    emit RocketPoolDepositAddressChanged(
      rocketPoolDeposit,
      newRocketPoolDepositAddress
    );
    rocketPoolDeposit = newRocketPoolDepositAddress;
  }

  fallback() external payable {}

  receive() external payable {}
}
