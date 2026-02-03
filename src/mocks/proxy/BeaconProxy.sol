// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "./Proxy.sol";
import "../../proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";
import "../../proxy/beacon/IBeaconUpgradeable.sol";

contract BeaconProxyMock is ProxyMock, ERC1967UpgradeUpgradeable {
    constructor(address beacon, bytes memory data) payable {
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    function _implementation() internal view virtual override returns (address) {
        return IBeaconUpgradeable(_getBeacon()).implementation();
    }
}
