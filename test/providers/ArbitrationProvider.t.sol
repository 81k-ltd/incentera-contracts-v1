// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ArbitrationProvider, UniversalAdapter} from "../../src/arbitration/UniversalAdapter.sol";
import {ProviderFixture} from "../fixtures/Deploy.sol";

contract ArbitrationProviderTest is ProviderFixture {
    function setUp() public virtual override {
        super.setUp();

        // deal link tokens to arbitrationProvider
        // assertEq link.balanceOf
    }

    function test_requestArbitration() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // assertEq returned requestId
        // expect emit event
    }

    function test_fulfillArbitration() public {
        // expect revert if not Universal Adapter (UA)
        // vm.prank UA
        // assertEq returned tuple
        // expect emit event
        // call into job distributor, although code has not yet been deployed so may need to use vm.etch
    }

    function test_changeUniversalAdapter() public {
        // vm.expectRevert onlyOwner
        // vm.prank owner
        // assertEq new address
    }

    function test_withdrawLink() public {
        // vm.expectRevert onlyOwner
        // vm.prank owner
        // withdraw
        // assertEq balance
    }
}
