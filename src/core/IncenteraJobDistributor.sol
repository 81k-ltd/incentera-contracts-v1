// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {DataTypes} from "../libraries/DataTypes.sol";
import {EnumerableSet} from "openzeppelin/utils/structs/EnumerableSet.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ArbitrationProvider} from "../arbitration/ArbitrationProvider.sol";
import {IncenteraReputation} from "./IncenteraReputation.sol";
import {IncenteraToken} from "./IncenteraToken.sol";
import {InflationProvider} from "../inflation/InflationProvider.sol";
// import {NotifProvider} from "../notif/NotifProvider.sol";
import {RandProvider} from "../rand/RandProvider.sol";

contract IncenteraJobDistributor is Owned {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint64 internal constant BPS_DENOMINATOR = 10_000;

    IncenteraReputation public immutable INCENTERA_REPUTATION;
    IncenteraToken public immutable INCENTERA_TOKEN;
    address public immutable ORACLE_NODE;

    ArbitrationProvider public s_arbitrationProvider;
    InflationProvider public s_inflationProvider;
    // NotifProvider public s_notifProvider;
    RandProvider public s_randProvider;
    address[] public s_participants;
    uint256 public s_jobIds;
    mapping(uint256 => uint256) public s_randomnessRequestToJobId;
    mapping(bytes32 => DataTypes.ArbitrationRequest) public s_arbitrationRequests;
    DataTypes.IncenteraJob[] public s_jobs;
    mapping(address => mapping(uint256 => uint256)) public s_participantStake;
    mapping(uint256 => EnumerableSet.AddressSet) s_pendingParticipants;

    /**
     * CONSTRUCTOR
     */
    constructor(
        IncenteraReputation _incenteraReputation,
        IncenteraToken _incenteraToken,
        address _oracleNode,
        ArbitrationProvider _arbitrationProvider,
        InflationProvider _inflationProvider,
        // NotifProvider _notifProvider,
        RandProvider _randProvider
    ) Owned(msg.sender) {
        INCENTERA_REPUTATION = _incenteraReputation;
        INCENTERA_TOKEN = _incenteraToken;
        ORACLE_NODE = _oracleNode;

        s_arbitrationProvider = _arbitrationProvider;
        s_inflationProvider = _inflationProvider;
        // s_notifProvider = _notifProvider;
        s_randProvider = _randProvider;
    }

    /**
     * ORACLE
     */
    function registerJob(bytes32 _jobHash, uint256 _timeout, DataTypes.Severities _severity) external onlyOracle {
        // listen to nina api for start updates, perform api call every x minutes, timeout after x minutes
        // save job info, on-chain and/or web3.storage/SxT
        // in reality, these functions would be all be callable by an oracle network coordinator contract
        // after participating nodes come to consensus on some threshold of signatures received

        uint256 multiplier = 11;
        // The branchless expression below is equivalent to:
        //      if (severity == 0) multiplier = 2;
        // else if (severity == 1) multiplier = 5;
        // else if (severity == 2) multiplier = 10;
        assembly {
            multiplier :=
                sub(sub(sub(multiplier, lt(_severity, 3)), mul(lt(_severity, 2), 5)), mul(lt(_severity, 1), 3))
        }

        uint256 id = s_jobs.length;
        s_jobs.push(
            DataTypes.IncenteraJob({
                jobHash: _jobHash,
                startTimestamp: uint32(block.timestamp),
                endTimestamp: 0,
                timeout: uint32(_timeout),
                severity: _severity,
                state: DataTypes.States.PENDING,
                multiplier: uint64(multiplier),
                reputationStake: uint64(multiplier * 1e18 / 2),
                minStake: 0.1 ether,
                crowdfundStake: 0,
                currentStake: 0,
                participants: new address[](0)
            })
        );

        s_randomnessRequestToJobId[_requestRandomSeed(uint8(_severity) + 1)] = id;

        emit Events.JobRegistered(id, _jobHash, s_participants);
    }

    // function checkJobUpkeep(uint256 _jobId) external onlyOracle {
    //     // monitor job participation acknowledgement (off-chain signature / on-chain stake)

    //     DataTypes.IncenteraJob memory job = s_jobs[_jobId];

    //     DataTypes.States state = job.state;
    //     uint32 timeoutTimestamp = job.startTimestamp + job.timeout;
    //     uint32 blockTimestamp = uint32(block.timestamp);

    //     if (state != DataTypes.States.PENDING || blockTimestamp < timeoutTimestamp) {
    //         revert Errors.InvalidRefreshJob(_jobId, blockTimestamp, timeoutTimestamp);
    //     }

    //     // if fully accepted, update state to ACTIVE
    //     // otherwise, select another subset and notify again
    //     // for now, assume all participants accept
    // }

    function endJob(uint256 _jobId) external onlyOracle onlyValidJob(_jobId) {
        // listen to nina api for end updates, load info & end

        DataTypes.IncenteraJob storage job = s_jobs[_jobId];

        job.endTimestamp = uint32(block.timestamp);
        job.state = DataTypes.States.ENDED;

        emit Events.JobEnded(_jobId);
    }

    function _onlyOracle() internal view {
        if (msg.sender != ORACLE_NODE) revert Errors.InvalidOracle(msg.sender);
    }

    modifier onlyOracle() {
        _onlyOracle();
        _;
    }

    /**
     * OWNER
     */
    function addParticipants(address[] memory participants) external onlyOwner {
        for (uint256 i; i < participants.length; ++i) {
            s_participants.push(participants[i]);
            INCENTERA_REPUTATION.mint(participants[i]);
        }
    }

    function addParticipant(address participant) external onlyOwner {
        _addParticipant(participant);
    }

    function _addParticipant(address participant) internal {
        s_participants.push(participant);
        INCENTERA_REPUTATION.mint(participant);
    }

    /**
     * USER
     */
    function stake(uint256 _jobId) external payable onlyParticipant(_jobId) onlyValidJob(_jobId) {
        // check stake/reputation required based on severity, e.g.
        //                  0 - 10 INT      10 - 50 INT     50+ INT
        // low:             20% stake       10% stake       5% stake
        // med:             40% stake       20% stake       10% stake
        // high:            60% stake       30% stake       15% stake

        address sender = msg.sender;
        uint256 tokenId = INCENTERA_REPUTATION.tokenIdFromOwner(sender);
        uint256 value = msg.value;
        DataTypes.IncenteraJob storage job = s_jobs[_jobId];
        uint256 minStakeRequirement =
            INCENTERA_REPUTATION.calculateMinStakeRequirement(s_jobs[_jobId].severity, tokenId);
        uint256 stakeRequired = (minStakeRequirement * job.multiplier * job.minStake) / BPS_DENOMINATOR;

        if (value < stakeRequired) revert Errors.InsufficientStake(sender, _jobId, value, stakeRequired);

        // TODO: in future, add some protocol fee
        INCENTERA_REPUTATION.lockReputation(tokenId, job.reputationStake);
        s_pendingParticipants[_jobId].remove(sender);
        job.participants.push(sender);
        job.currentStake += value;
        // TODO: track virtual shares of job stake (important for incentivised jobs which are essentially tokenised vaults)
        // for now, simply track balance and ignore crowdfund stake:
        s_participantStake[sender][_jobId] = value;
        if (s_pendingParticipants[_jobId].length() == 0) job.state = DataTypes.States.ACCEPTED;
    }

    function withdrawStake(uint256 _jobId) external onlyParticipant(_jobId) onlyValidJob(_jobId) {
        // for now, don't allow withdraw during pending
        // if (job.state == DataTypes.States.PENDING) {
        //     // remove sender from participants
        //     // remove stake from job struct
        //     // do transfer
        // }

        if (s_jobs[_jobId].state != DataTypes.States.ENDED) revert Errors.NotEnded();

        // First, check if participant was useful
        // Here, we are currently mocking the arbitration. In future, a number of different approaches could be taken:
        // for more data-driven arbitration, we could leverage any combination of Chainlink Direct Request via the Universal Adapter
        // and/or Filecoin Bacalhau and IoTeX metapebble, for example.
        // Subjective oracles, such as Kleros, or some Chainlink-native solution, are another option to consider.
        _requestArbitration(_jobId, msg.sender);
    }

    function incentivise(uint256 _jobId) external payable onlyValidJob(_jobId) {
        // perhaps we make this a platform for public goods alerting, i.e. non-participants can incentivise jobs they want to support
        s_jobs[_jobId].crowdfundStake += msg.value;
    }

    function _onlyValidJob(uint256 _jobId) internal view {
        if (s_jobs[_jobId].startTimestamp == 0) revert Errors.InvalidJob(_jobId);
    }

    modifier onlyValidJob(uint256 _jobId) {
        _onlyValidJob(_jobId);
        _;
    }

    function _isParticipant(uint256 jobId, address sender) internal view returns (bool) {
        return s_pendingParticipants[jobId].contains(sender) || s_participantStake[sender][jobId] != 0;
    }

    function _onlyParticipant(uint256 _jobId) internal view {
        if (!_isParticipant(_jobId, msg.sender)) revert Errors.InvalidParticipant(msg.sender, _jobId);
    }

    modifier onlyParticipant(uint256 jobId) {
        _onlyParticipant(jobId);
        _;
    }

    /**
     * RANDOMNESS
     */
    function _requestRandomSeed(uint32 numWords) internal returns (uint256) {
        return s_randProvider.requestRandomWords(numWords);
    }

    function acceptRandomWords(uint256 requestId, uint256[] calldata randomWords) external {
        if (msg.sender != address(s_randProvider)) revert Errors.InvalidRandProvider(msg.sender);

        uint256 length = randomWords.length;
        address[] memory participants = new address[](length);

        for (uint256 i; i < length; ++i) {
            // Issues may arise here if the same participant gets drawn twice, in which case `add` will return false
            // and the number of pending participants will not necessarily equal the number of random words requested.
            s_pendingParticipants[s_randomnessRequestToJobId[requestId]].add(
                s_participants[(randomWords[i] % s_participants.length) + 1]
            );
        }

        // _notifyParticipants(participants);

        emit Events.RandomnessAccepted(randomWords);
    }

    function upgradeRandProvider(RandProvider newRandProvider) external onlyOwner {
        // TODO: reset rand state to safeguard against malfunctions.

        emit Events.RandProviderUpgraded(s_randProvider = newRandProvider);
    }

    /**
     * NOTIFICATION
     */
    // Push app is only available on Ethereum and Polygon mainnet, so we shall not be using this for now
    // function _notifyParticipants(address[] memory participants) internal {
    //     s_notifProvider.notifyRecipients(participants);

    //     emit Events.ParticipantsNotified(participants);
    // }

    // function _notifyParticipant(address participant) internal {
    //     s_notifProvider.notifyRecipient(participant);

    //     // emit Events.ParticipantNotified(participant);
    // }

    // function upgradeNotifProvider(NotifProvider newNotifProvider) external onlyOwner {
    //     emit Events.NotifProviderUpgraded(s_notifProvider = newNotifProvider);
    // }

    /**
     * INFLATION
     */
    function _getInflation() internal view returns (int256) {
        return s_inflationProvider.getInflation();
    }

    // function _requestInflation() internal returns (bytes32) {
    //     // emit Events.InflationRequested(x, y);
    //     return s_inflationProvider.requestInflation();
    // }

    // function acceptInflation(
    //     bytes32,
    //     /* requestId */
    //     int256 inflation
    // ) external {
    //     if (msg.sender != address(s_inflationProvider)) revert Errors.InvalidInflationProvider(msg.sender);
    //
    //     // do something with fresh inflation data
    //
    //     emit Events.InflationAccepted(inflation);
    // }

    function upgradeInflationProvider(InflationProvider newInflationProvider) external onlyOwner {
        emit Events.InflationProviderUpgraded(s_inflationProvider = newInflationProvider);
    }

    /**
     * ARBITRATION
     */
    function _requestArbitration(uint256 jobId, address participant) internal returns (bytes32 requestId) {
        s_arbitrationRequests[requestId = s_arbitrationProvider.requestArbitration(jobId, participant)] =
            DataTypes.ArbitrationRequest({jobId: jobId, participant: participant});
        emit Events.ArbitrationRequested(jobId, requestId, participant);
    }

    function acceptArbitration(bytes32 requestId, bytes calldata arbitration) external {
        if (msg.sender != address(s_arbitrationProvider)) revert Errors.InvalidArbitrationProvider(msg.sender);

        (bool useful, uint256 amount) = abi.decode(arbitration, (bool, uint256));
        DataTypes.ArbitrationRequest memory req = s_arbitrationRequests[requestId];
        uint256 tokenId = INCENTERA_REPUTATION.tokenIdFromOwner(req.participant);
        uint256 stakeAmount = s_participantStake[req.participant][req.jobId];
        uint256 transferAmount;

        // if useful, transfer full amount + reward + inflation
        // unlock INT reputation + mint 1/4 job multiplier amount
        // else, transfer slashed amount
        // unlock INT reputation + burn 1/10 job multiplier amount
        // TODO: in future, also send share of crowdfund stake
        if (useful) {
            transferAmount = stakeAmount + amount;
            int256 inflation = _getInflation();
            transferAmount += inflation > 0 ? (uint256(inflation) * stakeAmount) / 100 : 0;
            INCENTERA_TOKEN.mint(tokenId, s_jobs[req.jobId].multiplier * 1e18 / 4);
        } else {
            transferAmount = stakeAmount - amount;
            INCENTERA_TOKEN.burn(tokenId, s_jobs[req.jobId].multiplier * 1e18 / 10);
        }

        INCENTERA_REPUTATION.unlockReputation(tokenId, s_jobs[req.jobId].reputationStake);
        (bool success, /* bytes memory result */ ) = req.participant.call{value: transferAmount}("");
        if (!success) revert Errors.TransferFailed(req.participant, transferAmount);

        emit Events.ArbitrationAccepted(requestId, req.participant, useful, amount);
    }

    function upgradeArbitrationProvider(ArbitrationProvider newArbitrationProvider) external onlyOwner {
        // TODO: reset arbitration state to safeguard against malfunctions.

        emit Events.ArbitrationProviderUpgraded(s_arbitrationProvider = newArbitrationProvider);
    }
}
