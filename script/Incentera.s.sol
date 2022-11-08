// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ArbitrationProvider, UniversalAdapter} from "../src/arbitration/UniversalAdapter.sol";
import {IncenteraJobDistributor} from "../src/core/IncenteraJobDistributor.sol";
import {IncenteraReputation} from "../src/core/IncenteraReputation.sol";
import {IncenteraToken} from "../src/core/IncenteraToken.sol";
import {InflationProvider, Truflation} from "../src/inflation/Truflation.sol";
import {NotifProvider, PushNotifProvider} from "../src/notif/PushNotifProvider.sol";
import {RandProvider, ChainlinkV2RandProvider} from "../src/rand/ChainlinkV2RandProvider.sol";
import "forge-std/Script.sol";

contract IncenteraScript is Script {
    ArbitrationProvider public arbitrationProvider;
    IncenteraToken public incenteraToken;
    IncenteraReputation public incenteraReputation;
    IncenteraJobDistributor public incenteraJobDistributor;
    InflationProvider public inflationProvider;
    NotifProvider public notifProvider;
    RandProvider public randProvider;
    address public incenteraJobDistributorAddress;
    address public incenteraReputationAddress;
    address[] public participants;
    uint256 deployerPrivateKey;
    address deployer;

    function setUp() public {
        deployerPrivateKey = vmSafe.envUint("PRIVATE_KEY");
        deployer = vmSafe.addr(deployerPrivateKey);
        uint256 nonce = vmSafe.getNonce(deployer);
        incenteraReputationAddress = computeCreateAddress(deployer, nonce + 5);
        incenteraJobDistributorAddress = computeCreateAddress(deployer, nonce + 6);
        participants =
            [makeAddr("gio"), makeAddr("mathias"), makeAddr("vitali"), makeAddr("tyrese"), makeAddr("amaechi")]; // TODO: these will be our EOAs for the purpose of demo
    }

    function run() public {
        vmSafe.startBroadcast(deployerPrivateKey);
        arbitrationProvider =
            new UniversalAdapter(IncenteraJobDistributor(incenteraJobDistributorAddress), address(0xDEADC0DE));
        inflationProvider = new Truflation(IncenteraJobDistributor(incenteraJobDistributorAddress));
        notifProvider = new PushNotifProvider(IncenteraJobDistributor(incenteraJobDistributorAddress));
        randProvider = new ChainlinkV2RandProvider(IncenteraJobDistributor(incenteraJobDistributorAddress), 1337);
        incenteraToken =
        new IncenteraToken(IncenteraJobDistributor(incenteraJobDistributorAddress), IncenteraReputation(incenteraReputationAddress));
        incenteraReputation =
            new IncenteraReputation(IncenteraJobDistributor(incenteraJobDistributorAddress), incenteraToken);
        incenteraJobDistributor = new IncenteraJobDistributor(incenteraReputation,
        incenteraToken, address(0xDEADC0DE),
        arbitrationProvider,
        inflationProvider,
        notifProvider,
        randProvider);
        vmSafe.stopBroadcast();

        require(incenteraReputationAddress == address(incenteraReputation), "reputation addr mismatch");
        require(incenteraJobDistributorAddress == address(incenteraJobDistributor), "job distributor addr mismatch");

        vmSafe.broadcast(deployerPrivateKey);
        incenteraJobDistributor.addParticipants(participants);
    }
}
