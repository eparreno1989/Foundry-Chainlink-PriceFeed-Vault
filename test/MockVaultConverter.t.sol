// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {VaultConverter} from "../src/VaultConverter.sol";
import {MockV3Aggregator} from "./mock/MockV3Aggregator.sol";

contract MockVaultConverterTest is Test {
    VaultConverter internal vault;
    MockV3Aggregator internal mockFeed;

    address internal owner = address(0x123);
    address internal user = address(0x456);

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // $2,000 USD per ETH

    function setUp() public {
        vm.startPrank(owner);
        // Deploy Mock Chainlink Price Feed (8 decimals, $2000/ETH)
        mockFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        // Pass mock address to constructor
        vault = new VaultConverter(address(mockFeed));
        vm.stopPrank();

        vm.deal(user, 10 ether);
    }

    function test_DepositUpdatesUsdBalance() public {
        vm.startPrank(user);
        vault.deposit{value: 2 ether}();
        vm.stopPrank();

        // 2 ETH * $2000 = $4000 (with 18 decimals)
        uint256 expectedUsd = 4000 * 1e18;
        uint256 userBalanceUsd = vault.s_addressToUsdBalance(user);

        assertEq(userBalanceUsd, expectedUsd);
    }

    function test_GetStateBalanceInUsdWithMock() public {
        vm.prank(user);
        vault.deposit{value: 5 ether}();

        // 5 ETH * $2000 = $10,000 USD
        uint256 expectedTotalUsd = 10000 * 1e18;
        uint256 actualUsdBalance = vault.getStateBalanceInUsd();

        assertEq(actualUsdBalance, expectedTotalUsd);
    }

    function test_WithdrawOnlyOwner() public {
        vm.prank(user);
        vault.deposit{value: 4 ether}();

        // Non-owner attempt should revert
        vm.prank(user);
        vm.expectRevert(VaultConverter.VaultConverter__NotOwner.selector);
        vault.withdraw();

        // Owner withdrawal should succeed
        uint256 initialOwnerBalance = owner.balance;
        vm.prank(owner);
        vault.withdraw();

        assertEq(address(vault).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + 4 ether);
    }
}
