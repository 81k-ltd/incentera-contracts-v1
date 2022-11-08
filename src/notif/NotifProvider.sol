// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

/// @title Notification Provider Interface
/// @notice Generic notification provider interface.
interface NotifProvider {
    function notifyRecipients(address[] memory recipients) external;
    function notifyRecipient(address recipient) external;
}
