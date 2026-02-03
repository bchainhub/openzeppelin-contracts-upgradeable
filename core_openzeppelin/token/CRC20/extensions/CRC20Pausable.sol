// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/ERC20Pausable.sol)

pragma solidity ^1.1.2;

import "../CRC20.sol";
import "../../../security/Pausable.sol";

/**
 * @dev CRC20 token with pausable token transfers, minting and burning.
 */
abstract contract CRC20Pausable is CRC20, Pausable {
    /**
     * @dev See {CRC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "CRC20Pausable: token transfer while paused");
    }
}
