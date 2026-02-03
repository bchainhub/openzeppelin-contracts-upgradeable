// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../../proxy/utils/UUPSUpgradeable.sol";

contract NonUpgradeableMockUpgradeable {
    uint256 internal _counter;

    function current() external view returns (uint256) {
        return _counter;
    }

    function increment() external {
        _counter += 1;
    }
}

contract UUPSUpgradeableMockUpgradeable is NonUpgradeableMockUpgradeable, UUPSUpgradeable {
    // Not having any checks in this function is dangerous! Do not do this outside tests!
    function _authorizeUpgrade(address) internal override {}
}

contract UUPSUpgradeableUnsafeMockUpgradeable is UUPSUpgradeableMockUpgradeable {
    function upgradeTo(address newImplementation) public override {
        ERC1967UpgradeUpgradeable._upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) public payable override {
        ERC1967UpgradeUpgradeable._upgradeToAndCall(newImplementation, data, false);
    }
}
