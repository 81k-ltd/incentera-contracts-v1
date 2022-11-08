// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ScriptFixture} from "../fixtures/Script.sol";

contract IncenteraScriptTest is ScriptFixture {
    function setUp() public virtual override {
        super.setUp();
        incenteraScript.setUp();
    }

    function test_run() public {
        incenteraScript.run();
        // assert contracts are deployed and working correctly, e.g.
        assertEq(
            incenteraScript.incenteraReputationAddress(),
            address(incenteraScript.incenteraJobDistributor().INCENTERA_REPUTATION())
        );
        assertEq(
            address(incenteraScript.incenteraToken()),
            address(incenteraScript.incenteraJobDistributor().INCENTERA_TOKEN())
        );
        // TODO: etc
    }
}
