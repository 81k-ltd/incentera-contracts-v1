// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ArbitrationProvider, UniversalAdapter} from "../src/arbitration/UniversalAdapter.sol";
import {IncenteraJobDistributor} from "../src/core/IncenteraJobDistributor.sol";
import {IncenteraReputation} from "../src/core/IncenteraReputation.sol";
import {IncenteraToken} from "../src/core/IncenteraToken.sol";
import {InflationProvider, Truflation} from "../src/inflation/Truflation.sol";
// import {NotifProvider, PushNotifProvider} from "../src/notif/PushNotifProvider.sol";
import {RandProvider, ChainlinkV2RandProvider} from "../src/rand/ChainlinkV2RandProvider.sol";
import "forge-std/Script.sol";

contract IncenteraScript is Script {
    ArbitrationProvider public arbitrationProvider;
    IncenteraToken public incenteraToken;
    IncenteraReputation public incenteraReputation;
    IncenteraJobDistributor public incenteraJobDistributor;
    InflationProvider public inflationProvider;
    // NotifProvider public notifProvider;
    RandProvider public randProvider;
    address public incenteraJobDistributorAddress;
    address public incenteraReputationAddress;
    address[] public participants;
    address public oracleNode;
    uint256 deployerPrivateKey;
    address deployer;

    function setUp() public {
        deployerPrivateKey = vmSafe.envUint("PRIVATE_KEY");
        deployer = vmSafe.addr(deployerPrivateKey);
        uint256 nonce = vmSafe.getNonce(deployer);
        incenteraReputationAddress = computeCreateAddress(deployer, nonce + 5);
        incenteraJobDistributorAddress = computeCreateAddress(deployer, nonce + 6);
        participants = [
            makeAddr("gio"),
            0x7CFc3bABf232f1199c8C7816529878D51f17A6dc,
            0x90FbA99F8Ee0d2B9564BEd0C245740E37Db570D1,
            makeAddr("tyrese"),
            0x42748b9E955410CEb6b4B165711C1f78bA92c8BF
        ]; // TODO: these will be our EOAs for the purpose of demo
        oracleNode = 0xb893F03c940399293B648533cEEB660D68e413EB;
    }

    function run() public {
        vmSafe.startBroadcast(deployerPrivateKey);
        arbitrationProvider =
            new UniversalAdapter(IncenteraJobDistributor(incenteraJobDistributorAddress), address(0xDEADC0DE));
        inflationProvider = new Truflation(IncenteraJobDistributor(incenteraJobDistributorAddress));
        // notifProvider = new PushNotifProvider(IncenteraJobDistributor(incenteraJobDistributorAddress));
        randProvider = new ChainlinkV2RandProvider(IncenteraJobDistributor(incenteraJobDistributorAddress), 6320);
        incenteraToken =
        new IncenteraToken(IncenteraJobDistributor(incenteraJobDistributorAddress), IncenteraReputation(incenteraReputationAddress));
        incenteraReputation =
            new IncenteraReputation(IncenteraJobDistributor(incenteraJobDistributorAddress), incenteraToken);
        incenteraJobDistributor = new IncenteraJobDistributor(incenteraReputation,
        incenteraToken, oracleNode,
        arbitrationProvider,
        inflationProvider,
        // notifProvider,
        randProvider);
        vmSafe.stopBroadcast();

        require(incenteraReputationAddress == address(incenteraReputation), "reputation addr mismatch");
        require(incenteraJobDistributorAddress == address(incenteraJobDistributor), "job distributor addr mismatch");

        vmSafe.broadcast(deployerPrivateKey);
        incenteraJobDistributor.addParticipants(participants);
    }
}
