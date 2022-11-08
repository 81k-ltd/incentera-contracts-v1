// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IncenteraScript} from "../../script/Incentera.s.sol";
import {Test} from "forge-std/Test.sol";

// Fixture which deploys the Incentera script contract
contract ScriptFixture is Test {
    IncenteraScript public incenteraScript;

    function setUp() public virtual {
        incenteraScript = new IncenteraScript();
    }
}
