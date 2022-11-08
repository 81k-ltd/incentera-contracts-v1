// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {Chainlink, ChainlinkClient, LinkTokenInterface} from "chainlink/ChainlinkClient.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {IncenteraJobDistributor} from "../core/IncenteraJobDistributor.sol";
import {InflationProvider} from "./InflationProvider.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {Strings} from "../libraries/Strings.sol";

contract Truflation is InflationProvider, ChainlinkClient, Owned {
    using Chainlink for Chainlink.Request;

    address public constant LINK_TOKEN = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    IncenteraJobDistributor public immutable INCENTERA_JOB_DISTRIBUTOR;

    address public s_oracleId = 0xcf72083697aB8A45905870C387dC93f380f2557b;
    string public s_jobId = "8b459447262a4ccf8863962e073576d9";
    uint256 public s_fee = 10e16;

    int256 public s_lastUpdate;
    mapping(bytes32 => bytes) public s_results;

    /**
     * CONSTRUCTOR
     */
    constructor(IncenteraJobDistributor _incenteraJobDistributor) Owned(msg.sender) {
        setChainlinkToken(LINK_TOKEN);
        INCENTERA_JOB_DISTRIBUTOR = _incenteraJobDistributor;
    }

    /**
     * REQUEST
     */
    function requestInflation() external returns (bytes32 requestId) {
        if (msg.sender != address(INCENTERA_JOB_DISTRIBUTOR)) {
            revert Errors.NotIncentera();
        }

        Chainlink.Request memory req =
            buildChainlinkRequest(bytes32(bytes(s_jobId)), address(this), this.fulfillInflation.selector);
        req.add("service", "truflation/current");
        req.add("data", "{'location':'us'}");
        req.add("keypath", "yearOverYearInflation");
        req.add("abi", "int256");
        req.add("multiplier", "1000000000000000000");

        emit Events.InflationRequested(requestId = sendChainlinkRequestTo(s_oracleId, req, s_fee));
    }

    function fulfillInflation(bytes32 requestId, bytes memory inflation)
        external
        recordChainlinkFulfillment(requestId)
    {
        int256 result = _toInt256(inflation);

        s_lastUpdate = result;
        s_results[requestId] = inflation;

        emit Events.InflationReturned(requestId, result);

        // INCENTERA_JOB_DISTRIBUTOR.acceptInflation(requestId, result);
    }

    function getInflation() external view returns (int256) {
        return s_lastUpdate;
    }

    /**
     * OWNER
     */
    function changeOracle(address _oracle) external onlyOwner {
        s_oracleId = _oracle;
    }

    function changeJobId(string memory _jobId) external onlyOwner {
        s_jobId = _jobId;
    }

    function changeFee(uint256 _fee) external onlyOwner {
        s_fee = _fee;
    }

    function withdrawLink() external onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(LINK_TOKEN);
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    /**
     * HELPER
     */
    function getInt256(bytes32 _requestId) external view returns (int256) {
        return _toInt256(s_results[_requestId]);
    }

    function _toInt256(bytes memory _bytes) internal pure returns (int256 value) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            value := mload(add(_bytes, 0x20))
        }
    }
}
