// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

/// @title Inflation Provider Interface
/// @notice Generic asynchronous inflation provider interface.
interface InflationProvider {
    /// @dev Request inflation int256 from the inflation provider.
    function requestInflation() external returns (bytes32 requestId);
    function fulfillInflation(bytes32 _requestId, bytes memory _inflation) external;
    function getInflation() external view returns (int256);
}
