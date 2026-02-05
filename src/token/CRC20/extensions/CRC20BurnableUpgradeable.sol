// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^1.1.2;

import "../CRC20Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {CRC20Upgradeable} that allows token holders to destroy
 * both their own tokens and those that they have an allowance for.
 */
abstract contract CRC20BurnableUpgradeable is Initializable, ContextUpgradeable, CRC20Upgradeable {
    function __CRC20Burnable_init() internal onlyInitializing {}

    function __CRC20Burnable_init_unchained() internal onlyInitializing {}

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
