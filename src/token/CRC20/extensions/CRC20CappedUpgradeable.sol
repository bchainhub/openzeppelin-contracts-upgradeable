// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^1.1.2;

import "../CRC20Upgradeable.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {CRC20Upgradeable} that adds a cap to the supply of tokens.
 */
abstract contract CRC20CappedUpgradeable is Initializable, CRC20Upgradeable {
    uint256 private _cap;

    function __CRC20Capped_init(uint256 cap_) internal onlyInitializing {
        __CRC20Capped_init_unchained(cap_);
    }

    function __CRC20Capped_init_unchained(uint256 cap_) internal onlyInitializing {
        require(cap_ > 0, "CRC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(CRC20Upgradeable.totalSupply() + amount <= cap(), "CRC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
