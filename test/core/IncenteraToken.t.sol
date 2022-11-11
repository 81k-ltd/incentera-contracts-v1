// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IncenteraToken} from "../../src/core/IncenteraToken.sol";
import {IncenteraFixture} from "../fixtures/Deploy.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract IncenteraTokenTest is IncenteraFixture {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public virtual override {
        super.setUp();
    }

    function test_mint() public {
        vm.expectRevert();
        incenteraToken.mint(1, 1);
        assertEq(incenteraToken.balanceOf(incenteraJobDistributorAddress), 0);
        assertEq(incenteraToken.reputation(0), 0);
        vm.prank(incenteraJobDistributorAddress);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(incenteraReputation), 1);
        incenteraToken.mint(1, 1);
    }

    function test_burn() public {
        vm.expectRevert();
        incenteraToken.burn(1, 1);
        assertEq(incenteraToken.balanceOf(incenteraJobDistributorAddress), 0);
        assertEq(incenteraToken.reputation(0), 0);
        vm.prank(incenteraJobDistributorAddress);
        incenteraToken.mint(1, 1);
        vm.prank(incenteraJobDistributorAddress);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(incenteraReputation), address(0), 1);
        incenteraToken.burn(1, 1);
    }
}
