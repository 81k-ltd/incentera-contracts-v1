// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {ArbitrationProvider} from "./ArbitrationProvider.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {IncenteraJobDistributor} from "../core/IncenteraJobDistributor.sol";
import {LinkTokenInterface} from "chainlink/interfaces/LinkTokenInterface.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract UniversalAdapter is ArbitrationProvider, Owned {
    address public constant LINK_TOKEN = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    IncenteraJobDistributor public immutable INCENTERA_JOB_DISTRIBUTOR;

    address public s_universalAdapter;

    constructor(IncenteraJobDistributor _incenteraJobDistributor, address _universalAdapter) Owned(msg.sender) {
        INCENTERA_JOB_DISTRIBUTOR = _incenteraJobDistributor;
        s_universalAdapter = _universalAdapter;
    }

    function requestArbitration(uint256 jobId, address participant) external returns (bytes32 requestId) {
        if (msg.sender != address(INCENTERA_JOB_DISTRIBUTOR)) {
            revert Errors.NotIncentera();
        }

        // TODO: call Universal Adapter
        requestId = bytes32(0);
        emit Events.ArbitrationRequested(requestId);
    }

    function fulfillArbitration(bytes32 requestId, bytes memory arbitration)
        external
        returns (bool useful, uint256 amount)
    {
        if (msg.sender != address(s_universalAdapter)) {
            revert Errors.NotUniversalAdapter();
        }

        // TODO: callback from Universal Adapter
        useful = true;
        amount = 1e17;

        emit Events.ArbitrationReturned(requestId, useful, amount);

        INCENTERA_JOB_DISTRIBUTOR.acceptArbitration(requestId, abi.encode(useful, amount));
    }

    /**
     * OWNER
     */
    function changeUniversalAdapter(address _universalAdapter) external onlyOwner {
        s_universalAdapter = _universalAdapter;
    }

    function withdrawLink() external onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(LINK_TOKEN);
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }
}
