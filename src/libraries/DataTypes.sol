// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

library DataTypes {
    /**
     * INCENTERA JOB DISTRIBUTOR
     */
    enum Severities {
        LOW,
        MEDIUM,
        HIGH
    }

    enum States {
        PENDING,
        ACCEPTED,
        ENDED
    }

    struct IncenteraJob {
        bytes32 jobHash;
        uint32 startTimestamp;
        uint32 endTimestamp;
        uint32 timeout;
        Severities severity;
        States state;
        uint64 multiplier;
        uint64 reputationStake;
        uint128 minStake;
        uint256 crowdfundStake;
        uint256 currentStake;
        address[] participants;
    }

    struct ArbitrationRequest {
        uint256 jobId;
        address participant;
    }

    /**
     * CHAINLINK V2 RAND PROVIDER
     */
    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }
}
