// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^1.1.2;

import "./Proxy.sol";
import "../../proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

/**
 * @dev Test proxy mock wired to ERC1967UpgradeUpgradeable.
 */
contract ERC1967ProxyMock is ProxyMock, ERC1967UpgradeUpgradeable {
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967UpgradeUpgradeable._getImplementation();
    }
}
