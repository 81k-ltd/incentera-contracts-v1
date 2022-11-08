// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IncenteraJobDistributor} from "../../src/core/IncenteraJobDistributor.sol";
import {IncenteraFixture} from "../fixtures/Deploy.sol";

contract IncenteraJobDistributorTest is IncenteraFixture {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_registerJob() public {
        // expect revert if not oracle node
        // vm.prank oracle node
        // assert job pending
        // expect emit event
    }

    function test_endJob() public {
        // expect revert if not oracle node
        // vm.prank oracle node
        // expect revert invalid job
        // assert job ended
        // expect emit event
    }

    function test_addParticipants() public {
        // expect revert pwner
        // vm.prank owner
        // assert participants balance
        // expect emit event
    }

    function test_addParticipant() public {
        // expect revert pwner
        // vm.prank owner
        // assert participant balance
        // expect emit event
    }

    function test_stake() public {
        // expect revert pwner
        // vm.prank participant
        // expect revert invalid job
        // expect revert insufficient stake
        // expect accepted if no more pending participants
    }

    function test_withdrawStake() public {
        // expect revert pwner
        // vm.prank participant
        // expect revert invalid job
        // expect revert not ended
        // expect emit request arbitration
    }

    function test_incentivise() public {
        // expect revert invalid job
        // assertEq balance
        // expect emit event (not yet added)
    }

    function test_acceptRandomWords() public {
        // expect revert invalid rand provider
        // vm.prank invalid rand provider
        // expect emit randomness accepted & participants notified events
    }

    function test_upgradeRandProvider() public {
        // expect revert pwner
        // vm.prank owner
        // assert new rand provider
        // expect emit event
    }

    function test_upgradeNotifProvider() public {
        // expect revert pwner
        // vm.prank owner
        // assert new notif provider
        // expect emit event
    }

    function test_upgradeInflationProvider() public {
        // expect revert pwner
        // vm.prank owner
        // assert new inflation provider
        // expect emit event
    }

    function test_acceptArbitration() public {
        // expect revert pwner
        // vm.prank arbitration provider
        // assert balance transfers & reputation unlock
        // expect emit event
    }

    function test_upgradeArbitrationProvider() public {
        // expect revert pwner
        // vm.prank owner
        // assert new arbitration provider
        // expect emit event
    }
}
