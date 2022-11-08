// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IncenteraReputation} from "../../src/core/IncenteraReputation.sol";
import {IncenteraFixture} from "../fixtures/Deploy.sol";

contract IncenteraReputationTest is IncenteraFixture {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_mint() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // expect revert existing participant
        // assertEq balance
        // expect emit event
    }

    function test_lockReputation() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // expect revert insufficient reputation
        // increase reputation (call token address or manipulate storage)
        // assertEq locked reputation
        // expect emit event (no event currently, maybe should add)
    }

    function test_unlockReputation() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // assertEq unlocked reputation (cached lockedReputation diff)
        // expect emit event (no event currently, maybe should add)
    }

    // test remaining functions if appropriate/time allows
}
