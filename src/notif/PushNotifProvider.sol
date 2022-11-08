// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {Events} from "../libraries/Events.sol";
import {Errors} from "../libraries/Errors.sol";
import {IPUSHCommInterface} from "./IPUSHCommInterface.sol";
import {IncenteraJobDistributor} from "../core/IncenteraJobDistributor.sol";
import {NotifProvider} from "./NotifProvider.sol";

contract PushNotifProvider is NotifProvider {
    address public constant EPNS_COMM_CONTRACT_ADDRESS_GOERLI = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa;
    address public constant CHANNEL_ADDRESS = address(0); // TODO from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel

    IncenteraJobDistributor public immutable INCENTERA_JOB_DISTRIBUTOR;

    constructor(IncenteraJobDistributor _incenteraJobDistributor) {
        INCENTERA_JOB_DISTRIBUTOR = _incenteraJobDistributor;
    }

    function notifyRecipients(address[] memory recipients) external {
        if (msg.sender != address(INCENTERA_JOB_DISTRIBUTOR)) revert Errors.NotIncentera();

        for (uint256 i; i < recipients.length; ++i) {
            _notifyRecipient(recipients[i]);
        }

        emit Events.RecipientsNotified(recipients);
    }

    function notifyRecipient(address recipient) external {
        if (msg.sender != address(INCENTERA_JOB_DISTRIBUTOR)) revert Errors.NotIncentera();

        _notifyRecipient(recipient);

        emit Events.RecipientNotified(recipient);
    }

    function _notifyRecipient(address recipient) internal {
        IPUSHCommInterface(EPNS_COMM_CONTRACT_ADDRESS_GOERLI).sendNotification(
            CHANNEL_ADDRESS,
            recipient, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs-developers.push.org/developer-guides/sending-notifications/notification-payload-types/notification-standard-advanced/notification-identity
                        "+", // segregator
                        "3", // this is payload type: https://docs-developers.push.org/developer-guides/sending-notifications/notification-payload-types/notification-standard-advanced/notification-payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Title", // this is notificaiton title
                        "+", // segregator
                        "Body" // notification body
                    )
                )
            )
        );
    }
}
