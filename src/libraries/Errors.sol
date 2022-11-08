// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {DataTypes} from "./DataTypes.sol";

library Errors {
    error ExistingParticipant(address participant);
    error InsufficientReputation(uint256 tokenId, uint256 amount);
    error InsufficientStake(address sender, uint256 jobId, uint256 amountSent, uint256 amountRequired);
    error InvalidArbitrationProvider(address sender);
    error InvalidInflationProvider(address sender);
    error InvalidJob(uint256 jobId);
    error InvalidOracle(address sender);
    error InvalidParticipant(address sender, uint256 jobId);
    error InvalidRefreshJob(uint256 jobId, uint32 blockTimestamp, uint32 timeoutTimestamp);
    error InvalidRandProvider(address sender);
    error InvalidToken(uint256 tokenId);
    error NotEnded();
    error NotIncentera();
    error NotUniversalAdapter();
    error TransferFailed(address participant, uint256 transferAmount);
}
