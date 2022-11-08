// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {IncenteraJobDistributor} from "./IncenteraJobDistributor.sol";
import {IncenteraToken} from "./IncenteraToken.sol";
import {DataURI, Render} from "../libraries/Render.sol";
import {Strings} from "../libraries/Strings.sol";
import {svg} from "hot-chain-svg/SVG.sol";
import {utils} from "hot-chain-svg/Utils.sol";

contract IncenteraReputation is ERC721("Incentera Reputation", "INT-R") {
    using DataURI for string;
    using Strings for address;

    uint256 public constant INTERMEDIATE_THRESHOLD = 10;
    uint256 public constant ADVANCED_THRESHOLD = 50;

    IncenteraJobDistributor public immutable JOB_DISTRIBUTOR;
    IncenteraToken public immutable INCENTERA_TOKEN;

    uint256 public s_tokenIds;
    mapping(address => uint256) s_ownerToTokenId;
    mapping(uint256 => uint256) s_lockedReputations;

    constructor(IncenteraJobDistributor _jobDistributor, IncenteraToken _incenteraToken) {
        JOB_DISTRIBUTOR = _jobDistributor;
        INCENTERA_TOKEN = _incenteraToken;
    }

    function mint(address to) external onlyDistributor {
        if (s_ownerToTokenId[to] != 0) revert Errors.ExistingParticipant(to);
        uint256 id = ++s_tokenIds;
        s_ownerToTokenId[to] = id;
        _safeMint(to, id);
    }

    function lockReputation(uint256 tokenId, uint256 amount) public onlyDistributor {
        if (INCENTERA_TOKEN.reputation(tokenId) - s_lockedReputations[tokenId] < amount) {
            revert Errors.InsufficientReputation(tokenId, amount);
        }
        s_lockedReputations[tokenId] += amount;
    }

    function unlockReputation(uint256 tokenId, uint256 amount) public onlyDistributor {
        s_lockedReputations[tokenId] -= amount;
    }

    function lockedReputation(uint256 tokenId) external view returns (uint256) {
        return s_lockedReputations[tokenId];
    }

    function calculateMinStakeRequirement(DataTypes.Severities _severity, uint256 tokenId)
        external
        view
        returns (uint256 minStake)
    {
        uint256 reputation = INCENTERA_TOKEN.reputation(tokenId);

        if (reputation < INTERMEDIATE_THRESHOLD) {
            minStake = (uint8(_severity) + 1) * 2_000;
        } else if (reputation < ADVANCED_THRESHOLD) {
            minStake = (uint8(_severity) + 1) * 1_000;
        } else {
            minStake = (uint8(_severity) + 1) * 500;
        }
    }

    function tokenIdFromOwner(address owner) external view returns (uint256) {
        return s_ownerToTokenId[owner];
    }

    function tokenJSON(uint256 _tokenId) public view onlyExistingToken(_tokenId) returns (string memory) {
        address owner = _ownerOf[_tokenId];
        uint256 reputation = INCENTERA_TOKEN.reputation(_tokenId);
        uint256 reputationLocked = s_lockedReputations[_tokenId];
        return Render.json(
            _tokenId,
            tokenSVG(_tokenId, owner, reputation, reputationLocked).toDataURI("image/svg+xml"),
            owner,
            getReputationString(reputation),
            reputation,
            reputationLocked
        );
    }

    function tokenSVG(uint256 _tokenId, address _owner, uint256 _reputation, uint256 _reputationLocked)
        public
        view
        onlyExistingToken(_tokenId)
        returns (string memory)
    {
        return Render.image(_tokenId, _owner, getReputationString(_reputation), _reputation, _reputationLocked);
    }

    function tokenURI(uint256 _tokenId) public view override onlyExistingToken(_tokenId) returns (string memory uri) {
        return tokenJSON(_tokenId).toDataURI("application/json");
    }

    function getReputationString(uint256 reputation) public pure returns (string memory level) {
        level = reputation < INTERMEDIATE_THRESHOLD
            ? "NOVICE"
            : reputation < ADVANCED_THRESHOLD ? "INTERMEDIATE" : "ADVANCED";
    }

    function _onlyExistingToken(uint256 _tokenId) internal view {
        if (_ownerOf[_tokenId] == address(0)) revert Errors.InvalidToken(_tokenId);
    }

    modifier onlyExistingToken(uint256 _tokenId) {
        _onlyExistingToken(_tokenId);
        _;
    }

    function _onlyDistributor() internal view {
        if (msg.sender != address(JOB_DISTRIBUTOR)) revert Errors.NotIncentera();
    }

    modifier onlyDistributor() {
        _onlyDistributor();
        _;
    }
}
