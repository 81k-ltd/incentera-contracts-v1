// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

/// @title Arbitration Provider Interface
/// @notice Generic asynchronous arbitration provider interface.
interface ArbitrationProvider {
    /// @dev Request arbitration result from the arbitration provider.
    function requestArbitration(uint256 jobId, address participant) external returns (bytes32 requestId);
    function fulfillArbitration(bytes32 requestId, bytes memory arbitration)
        external
        returns (bool useful, uint256 amount);
}
