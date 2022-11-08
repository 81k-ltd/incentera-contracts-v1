// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Base64} from "base64/base64.sol";
import {Strings} from "./Strings.sol";
import {svg} from "hot-chain-svg/SVG.sol";
import {utils} from "hot-chain-svg/Utils.sol";

library DataURI {
    function toDataURI(string memory data, string memory mimeType) internal pure returns (string memory) {
        return string.concat("data:", mimeType, ";base64,", Base64.encode(abi.encodePacked(data)));
    }
}

// solhint-disable quotes
library Render {
    function json(
        uint256 _tokenId,
        string memory _svg,
        address _owner,
        string memory _level,
        uint256 _reputation,
        uint256 _reputationLocked
    ) internal pure returns (string memory) {
        return string.concat(
            '{"name": "Incentera, token',
            " #",
            utils.uint2str(_tokenId),
            '", "description": "A trust-minimised reputation system for incentivised public health alerting", "image": "',
            _svg,
            '", "attributes": ',
            attributes(_owner, _level, _reputation, _reputationLocked),
            "}"
        );
    }

    function attributes(address _owner, string memory _level, uint256 _reputation, uint256 _reputationLocked)
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "[",
            attribute("Owner", Strings.substringAddress(_owner)),
            ",",
            attribute("Level", _level),
            ",",
            attribute("Reputation", utils.uint2str(_reputation)),
            ",",
            attribute("Reputation Locked", utils.uint2str(_reputationLocked)),
            "]"
        );
    }

    function attribute(string memory name, string memory value) internal pure returns (string memory) {
        return string.concat('{"trait_type": "', name, '", "value": "', value, '"}');
    }

    function image(
        uint256 _tokenId,
        address _owner,
        string memory _level,
        uint256 _reputation,
        uint256 _lockedReputation
    ) internal pure returns (string memory) {
        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" style="background:#252e42">',
            svg.text(
                string.concat(
                    svg.prop("x", "20"), svg.prop("y", "40"), svg.prop("font-size", "22"), svg.prop("fill", "white")
                ),
                string.concat(svg.cdata("Incentera, token #"), utils.uint2str(_tokenId))
            ),
            svg.rect(
                string.concat(
                    svg.prop("fill", "#05c46b"),
                    svg.prop("x", "20"),
                    svg.prop("y", "50"),
                    svg.prop("width", utils.uint2str(200)),
                    svg.prop("height", utils.uint2str(10))
                ),
                utils.NULL
            ),
            svg.text(
                string.concat(
                    svg.prop("x", "20"), svg.prop("y", "100"), svg.prop("font-size", "22"), svg.prop("fill", "white")
                ),
                string.concat(svg.cdata("Owner: "), Strings.substringAddress(_owner))
            ),
            svg.text(
                string.concat(
                    svg.prop("x", "20"), svg.prop("y", "140"), svg.prop("font-size", "22"), svg.prop("fill", "white")
                ),
                string.concat(svg.cdata("Reputation Level: "), _level)
            ),
            svg.text(
                string.concat(
                    svg.prop("x", "20"), svg.prop("y", "180"), svg.prop("font-size", "22"), svg.prop("fill", "white")
                ),
                string.concat(svg.cdata("Total Reputation: "), utils.uint2str(_reputation))
            ),
            svg.text(
                string.concat(
                    svg.prop("x", "20"), svg.prop("y", "220"), svg.prop("font-size", "22"), svg.prop("fill", "white")
                ),
                string.concat(svg.cdata("Reputation Locked: "), utils.uint2str(_lockedReputation))
            ),
            "</svg>"
        );
    }
}
// solhint-enable quotes
