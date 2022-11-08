// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {DataTypes} from "../libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {IncenteraJobDistributor} from "../core/IncenteraJobDistributor.sol";
import {RandProvider} from "./RandProvider.sol";
import {VRFConsumerBaseV2} from "chainlink/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "chainlink/interfaces/VRFCoordinatorV2Interface.sol";

contract ChainlinkV2RandProvider is RandProvider, VRFConsumerBaseV2 {
    /**
     * CONSTANTS
     */
    VRFCoordinatorV2Interface public constant COORDINATOR =
        VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
    bytes32 public constant KEYHASH = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 public constant CALLBACK_GAS_LIMIT = 100000;
    uint16 public constant REQUEST_CONFIRMATIONS = 3;

    /**
     * IMMUTABLES
     */
    IncenteraJobDistributor public immutable INCENTERA_JOB_DISTRIBUTOR;
    uint64 public immutable SUBSCRIPTION_ID;

    /**
     * STORAGE
     */
    mapping(uint256 => DataTypes.RequestStatus) public s_requests;
    uint256[] public s_requestIds;
    uint256 public s_lastRequestId;

    /**
     * CONSTRUCTOR
     */
    constructor(IncenteraJobDistributor _incenteraJobDistributor, uint64 _subscriptionId)
        VRFConsumerBaseV2(address(COORDINATOR))
    {
        INCENTERA_JOB_DISTRIBUTOR = _incenteraJobDistributor;
        SUBSCRIPTION_ID = _subscriptionId;
    }

    /// @notice Request random words from Chainlink VRF. Can only by called by the IncenteraJobDistributor contract.
    function requestRandomWords(uint32 numWords) external returns (uint256 requestId) {
        if (msg.sender != address(INCENTERA_JOB_DISTRIBUTOR)) revert Errors.NotIncentera();

        requestId = COORDINATOR.requestRandomWords(
            KEYHASH, SUBSCRIPTION_ID, REQUEST_CONFIRMATIONS, CALLBACK_GAS_LIMIT, numWords
        );
        s_requests[requestId] = DataTypes.RequestStatus({randomWords: new uint256[](0), exists: true, fulfilled: false});
        s_requestIds.push(requestId);
        s_lastRequestId = requestId;
        emit Events.RandomWordsRequested(requestId, numWords);
    }

    /// @dev Handles VRF response by calling back into the IncenteraJobDistributor contract.
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit Events.RandomWordsReturned(_requestId, _randomWords);

        INCENTERA_JOB_DISTRIBUTOR.acceptRandomWords(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "request not found");
        DataTypes.RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}
