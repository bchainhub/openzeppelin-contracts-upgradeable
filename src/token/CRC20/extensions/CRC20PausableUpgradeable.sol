// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/ERC20Pausable.sol)

pragma solidity ^1.1.2;

import "../CRC20Upgradeable.sol";
import "../../../security/PausableUpgradeable.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev CRC20 token with pausable token transfers, minting and burning.
 */
abstract contract CRC20PausableUpgradeable is Initializable, CRC20Upgradeable, PausableUpgradeable {
    function __CRC20Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __CRC20Pausable_init_unchained() internal onlyInitializing {}

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "CRC20Pausable: token transfer while paused");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
