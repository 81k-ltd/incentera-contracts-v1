// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

/// @title Randomness Provider Interface
/// @notice Generic asynchronous randomness provider interface.
interface RandProvider {
    /// @dev Request random bytes from the randomness provider.
    function requestRandomWords(uint32 numWords) external returns (uint256 requestId);
}
