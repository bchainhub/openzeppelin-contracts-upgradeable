// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (metatx/ERC2771Context.sol)

pragma solidity ^1.1.2;

import "../utils/Context.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771Context is Context {
    address private immutable _trustedForwarder;

    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        uint256 calldataLength = msg.data.length;
        uint256 contextSuffixLength = _contextSuffixLength();

        if (isTrustedForwarder(msg.sender) && calldataLength >= contextSuffixLength) {
            assembly {
                sender := shr(80, calldataload(sub(calldatasize(), contextSuffixLength)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        uint256 calldataLength = msg.data.length;
        uint256 contextSuffixLength = _contextSuffixLength();
        if (isTrustedForwarder(msg.sender) && calldataLength >= contextSuffixLength) {
            return msg.data[:calldataLength - contextSuffixLength];
        } else {
            return super._msgData();
        }
    }

    /**
     * @dev ERC-2771 specifies the context as being a single address.
     */
    function _contextSuffixLength() internal view virtual override returns (uint256) {
        return 22;
    }
}
