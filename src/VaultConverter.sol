// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/// @title Chainlink PriceFeed Vault
/// @notice A vault contract that accepts ETH deposits and maintains internal USD accounting via Chainlink Data Feeds.
contract VaultConverter {
    // State variables
    AggregatorV3Interface public immutable i_priceFeed;
    address public immutable i_owner;

    // Custom errors for gas efficiency
    error VaultConverter__NotOwner();
    error VaultConverter__InvalidPrice();
    error VaultConverter__TransferFailed();
    error VaultConverter__DepositZero();

    // Mapping for internal USD balance accounting (user => balanceInUsd)
    mapping(address => uint256) public s_addressToUsdBalance;

    // Events
    event Deposited(address indexed sender, uint256 ethAmount, uint256 usdValue);
    event Withdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert VaultConverter__NotOwner();
        _;
    }

    /// @param priceFeedAddress The address of the Chainlink AggregatorV3 price feed contract
    constructor(address priceFeedAddress) {
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_owner = msg.sender;
    }

    /// @notice Allows users to deposit ETH and updates their USD balance in internal accounting
    function deposit() public payable {
        if (msg.value == 0) revert VaultConverter__DepositZero();

        uint256 usdAmount = getUsdValue(msg.value);
        s_addressToUsdBalance[msg.sender] += usdAmount;

        emit Deposited(msg.sender, msg.value, usdAmount);
    }

    /// @notice Calculates the total ETH balance of the vault converted to USD (18 decimals)
    function getStateBalanceInUsd() external view returns (uint256) {
        return getUsdValue(address(this).balance);
    }

    /// @notice Retrieves the latest ETH/USD price from Chainlink Price Feed (18 decimals precision)
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price,,,) = i_priceFeed.latestRoundData();
        if (price <= 0) revert VaultConverter__InvalidPrice();

        // Chainlink ETH/USD feed returns 8 decimals; we scale it up to 18 decimals
        return uint256(price) * 1e10;
    }

    /// @notice Converts a given ETH amount (in Wei) to its equivalent value in USD (18 decimals)
    function getUsdValue(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getCurrentPrice();
        // (ETH Amount in Wei * ETH Price in 18 decimals) / 1e18
        return (ethAmount * ethPrice) / 1e18;
    }

    /// @notice Withdraws the total ETH balance of the vault to the contract owner
    function withdraw() external onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        (bool sent,) = i_owner.call{value: balance}("");
        if (!sent) revert VaultConverter__TransferFailed();

        emit Withdrawn(i_owner, balance);
        return sent;
    }

    // Fallback and receive to handle direct ETH transfers
    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }
}
