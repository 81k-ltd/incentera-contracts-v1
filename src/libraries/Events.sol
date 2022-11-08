// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {DataTypes} from "./DataTypes.sol";
import {ArbitrationProvider} from "../arbitration/ArbitrationProvider.sol";
import {InflationProvider} from "../inflation/InflationProvider.sol";
import {NotifProvider} from "../notif/NotifProvider.sol";
import {RandProvider} from "../rand/RandProvider.sol";

library Events {
    /**
     * INCENTERA JOB DISTRIBUTOR
     */
    event ArbitrationAccepted(bytes32 requestId, address participant, bool useful, uint256 amount);
    event ArbitrationProviderUpgraded(ArbitrationProvider newArbitrationProvider);
    event ArbitrationRequested(uint256 jobId, bytes32 requestId, address participant);
    event InflationAccepted(int256 inflation);
    event InflationProviderUpgraded(InflationProvider newInflationProvider);
    event JobRegistered(uint256 jobId, bytes32 jobHash, address[] participants);
    event JobEnded(uint256 jobId);
    event NotifProviderUpgraded(NotifProvider newNotifProvider);
    event ParticipantsNotified(address[] participants);
    event RandomnessAccepted(uint256[] randomWords);
    event RandProviderUpgraded(RandProvider newRandProvider);

    /**
     * ARBITRATION PROVIDER
     */
    event ArbitrationRequested(bytes32 requestId);
    event ArbitrationReturned(bytes32 requestId, bool result, uint256 amount);

    /**
     * CHAINLINK V2 RAND PROVIDER
     */
    event RandomWordsRequested(uint256 requestId, uint256 numWords);
    event RandomWordsReturned(uint256 requestId, uint256[] randomWords);

    /**
     * PUSH NOTIF PROVIDER
     */
    event RecipientsNotified(address[] recipients);
    event RecipientNotified(address recipient);

    /**
     * TRUFLATION
     */
    event InflationRequested(bytes32 requestId);
    event InflationReturned(bytes32 requestId, int256 inflation);
}
