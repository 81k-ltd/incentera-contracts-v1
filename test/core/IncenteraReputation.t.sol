// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IncenteraReputation} from "../../src/core/IncenteraReputation.sol";
import {IncenteraFixture} from "../fixtures/Deploy.sol";

contract IncenteraReputationTest is IncenteraFixture {
    function setUp() public virtual override {
        super.setUp();
    }

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    function test_mint() public {
        address newParticipant = makeAddr("newParticipant");
        address newParticipant1 = makeAddr("newParticipant1");

        vm.expectRevert();
        incenteraReputation.mint(newParticipant);

        vm.startPrank(incenteraJobDistributorAddress);
        incenteraReputation.mint(newParticipant);
        assertEq(incenteraReputation.balanceOf(newParticipant), 1);

        vm.expectRevert();
        incenteraReputation.mint(newParticipant);

        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), newParticipant1, 7);
        incenteraReputation.mint(newParticipant1);
        vm.stopPrank();
    }

    function test_lockReputation() public {
        vm.expectRevert();
        incenteraReputation.lockReputation(1, 1);
        vm.startPrank(incenteraJobDistributorAddress);
        vm.expectRevert();
        incenteraReputation.lockReputation(1, 1);
        incenteraToken.mint(1, 1);
        incenteraReputation.lockReputation(1, 1);
        assertEq(incenteraReputation.lockedReputation(1), 1);
        // expect emit event (no event currently, maybe should add)
    }

    function test_unlockReputation() public {
        vm.expectRevert();
        incenteraReputation.unlockReputation(1, 1);
        vm.startPrank(incenteraJobDistributorAddress);
        incenteraReputation.unlockReputation(1, 1);
        // expect emit event (no event currently, maybe should add)
    }

    // test remaining functions if appropriate/time allows
}
