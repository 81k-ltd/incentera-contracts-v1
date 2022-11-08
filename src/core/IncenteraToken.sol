// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Errors} from "../libraries/Errors.sol";
import {IncenteraJobDistributor} from "./IncenteraJobDistributor.sol";
import {IncenteraReputation} from "./IncenteraReputation.sol";

contract IncenteraToken is ERC20("Incentera Token", "INT", 18) {
    address public immutable JOB_DISTRIBUTOR;
    address public immutable INCENTERA_REPUTATION;
    mapping(uint256 => uint256) s_reputations;

    constructor(IncenteraJobDistributor _jobDistributor, IncenteraReputation _incenteraReputation) {
        JOB_DISTRIBUTOR = address(_jobDistributor);
        INCENTERA_REPUTATION = address(_incenteraReputation);
    }

    function reputation(uint256 tokenId) external view returns (uint256) {
        return s_reputations[tokenId];
    }

    function mint(uint256 amount, uint256 tokenId) external onlyDistributor {
        s_reputations[tokenId] += amount;
        _mint(INCENTERA_REPUTATION, amount);
    }

    function burn(uint256 amount, uint256 tokenId) external onlyDistributor {
        s_reputations[tokenId] -= amount;
        _burn(INCENTERA_REPUTATION, amount);
    }

    function _onlyDistributor() internal view {
        address sender = msg.sender;
        if (sender != JOB_DISTRIBUTOR) revert Errors.NotIncentera();
    }

    modifier onlyDistributor() {
        _onlyDistributor();
        _;
    }
}
