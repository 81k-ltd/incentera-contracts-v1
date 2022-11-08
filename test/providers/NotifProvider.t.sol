// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {NotifProvider, PushNotifProvider} from "../../src/notif/PushNotifProvider.sol";
import {ProviderFixture} from "../fixtures/Deploy.sol";

contract NotifProviderTest is ProviderFixture {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_notifyRecipients() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // expect emit event
    }

    function test_notifyRecipient() public {
        // expect revert if not job distributor
        // vm.prank job distributor
        // expect emit event
    }
}
