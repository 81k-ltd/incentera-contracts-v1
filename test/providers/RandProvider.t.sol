// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {RandProvider, ChainlinkV2RandProvider} from "../../src/rand/ChainlinkV2RandProvider.sol";
import {ProviderFixture} from "../fixtures/Deploy.sol";

contract RandProviderTest is ProviderFixture {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_requestRandomWords() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // assertEq returned requestId
        // expect emit event
    }

    function test_fulfillRandomWords() public {
        // internal function which gets called through oracle network contracts
        // job distributor address currently also has no code
        // so perhaps mock and/or vm.etch

        // expect revert non-existent request
        // assertEq returned result
        // expect emit event
    }

    function test_getRequestStatus() public {
        // expect revert non-existent request
        // assertEq returned result
    }
}
