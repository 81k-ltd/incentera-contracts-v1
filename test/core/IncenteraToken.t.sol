// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IncenteraToken} from "../../src/core/IncenteraToken.sol";
import {IncenteraFixture} from "../fixtures/Deploy.sol";

contract IncenteraTokenTest is IncenteraFixture {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_mint() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // assertEq incentera reputation contract balance
        // assertEq tokenId s_reputations 'balance'
        // expect emit event
    }

    function test_burn() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // assertEq incentera reputation contract balance
        // assertEq tokenId s_reputations 'balance'
        // expect emit event
    }
}
