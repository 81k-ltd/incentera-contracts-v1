// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ArbitrationProvider, UniversalAdapter} from "../../src/arbitration/UniversalAdapter.sol";
import {IncenteraJobDistributor} from "../../src/core/IncenteraJobDistributor.sol";
import {IncenteraReputation} from "../../src/core/IncenteraReputation.sol";
import {IncenteraToken} from "../../src/core/IncenteraToken.sol";
import {InflationProvider, Truflation} from "../../src/inflation/Truflation.sol";
// import {NotifProvider, PushNotifProvider} from "../../src/notif/PushNotifProvider.sol";
import {RandProvider, ChainlinkV2RandProvider} from "../../src/rand/ChainlinkV2RandProvider.sol";
import {DataTypes} from "../../src/libraries/DataTypes.sol";
import {utils} from "hot-chain-svg/Utils.sol";
import {Test} from "forge-std/Test.sol";

// Fixture which deploys the peripheral provider contracts
contract ProviderFixture is Test {
    ArbitrationProvider public arbitrationProvider;
    InflationProvider public inflationProvider;
    // NotifProvider public notifProvider;
    RandProvider public randProvider;
    address public incenteraJobDistributorAddress;
    address public owner;
    address public pwner;

    function setUp() public virtual {
        owner = makeAddr("owner");
        pwner = makeAddr("pwner");

        incenteraJobDistributorAddress = computeCreateAddress(owner, vm.getNonce(owner) + 6);

        vm.startPrank(owner, owner);
        arbitrationProvider =
            new UniversalAdapter(IncenteraJobDistributor(incenteraJobDistributorAddress), address(0xDEADC0DE));
        inflationProvider = new Truflation(IncenteraJobDistributor(incenteraJobDistributorAddress));
        // notifProvider = new PushNotifProvider(IncenteraJobDistributor(incenteraJobDistributorAddress));
        randProvider = new ChainlinkV2RandProvider(IncenteraJobDistributor(incenteraJobDistributorAddress), 1337);
        vm.stopPrank();
    }
}

// Fixture which deploys the core Incentera contracts
contract IncenteraFixture is ProviderFixture {
    IncenteraJobDistributor public incenteraJobDistributor;
    IncenteraReputation public incenteraReputation;
    IncenteraToken public incenteraToken;
    address[] public participants;

    function setUp() public virtual override {
        super.setUp();

        for (uint256 i; i < 5; ++i) {
            participants.push(makeAddr(string.concat("usr", utils.uint2str(i + 1))));
        }

        address incenteraReputationAddress = computeCreateAddress(owner, vm.getNonce(owner) + 1);

        vm.startPrank(owner, owner);
        incenteraToken =
        new IncenteraToken(IncenteraJobDistributor(incenteraJobDistributorAddress), IncenteraReputation(incenteraReputationAddress));
        incenteraReputation =
            new IncenteraReputation(IncenteraJobDistributor(incenteraJobDistributorAddress), incenteraToken);

        assertEq(incenteraReputationAddress, address(incenteraReputation));

        incenteraJobDistributor = new IncenteraJobDistributor(incenteraReputation,
        incenteraToken, address(0xDEADC0DE),
        arbitrationProvider,
        inflationProvider,
        // notifProvider,
        randProvider);

        assertEq(incenteraJobDistributorAddress, address(incenteraJobDistributor));

        incenteraJobDistributor.addParticipants(participants);
        vm.stopPrank();
    }
}
