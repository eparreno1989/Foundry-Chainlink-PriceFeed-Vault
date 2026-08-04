// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {VaultConverter} from "../src/VaultConverter.sol";

contract ForkVaultConverterTest is Test {
    VaultConverter internal vault;
    
    // Mainnet ETH/USD Price Feed Address
    address public constant MAINNET_ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address internal owner = address(0x123);
    address internal user = address(0x456);

    function setUp() public {
        // Deploy vault injecting real Mainnet Price Feed address
        vm.prank(owner);
        vault = new VaultConverter(MAINNET_ETH_USD_FEED);

        vm.deal(user, 10 ether);
    }

    function test_GetCurrentPriceFromMainnetFork() public view {
        uint256 price = vault.getCurrentPrice();
        // Real ETH price should be greater than $0
        assertGt(price, 0);
    }

    function test_DepositAndCheckUsdValueFork() public {
        vm.prank(user);
        vault.deposit{value: 1 ether}();

        uint256 currentEthPrice = vault.getCurrentPrice();
        uint256 totalVaultUsd = vault.getStateBalanceInUsd();

        // Deposit of 1 ETH must match current 1 ETH price in USD
        assertEq(totalVaultUsd, currentEthPrice);
    }
}