// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {InflationProvider, Truflation} from "../../src/inflation/Truflation.sol";
import {ProviderFixture} from "../fixtures/Deploy.sol";

contract InflationProviderTest is ProviderFixture {
    function setUp() public virtual override {
        super.setUp();

        // deal link tokens to inflationProvider
        // assertEq link.balanceOf
    }

    function test_requestInflation() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // assertEq returned requestId
        // expect emit event
    }

    function test_fulfillInflation() public {
        // expect revert if not oracle node
        // vm.prank s_oracleId
        // assertEq returned result
        // expect emit event
    }

    function test_getInflation() public {
        // assertEq cached update
    }

    function test_changeOracle() public {
        // vm.expectRevert onlyOwner
        // vm.prank owner
        // assertEq new address
    }

    function test_JobId() public {
        // vm.expectRevert onlyOwner
        // vm.prank owner
        // assertEq new id
    }

    function test_changeFee() public {
        // vm.expectRevert onlyOwner
        // vm.prank owner
        // assertEq new fee
    }

    function test_withdrawLink() public {
        // vm.expectRevert onlyOwner
        // vm.prank owner
        // withdraw
        // assertEq balance
    }
}
