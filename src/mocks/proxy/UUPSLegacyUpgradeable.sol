// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "./UUPSUpgradeableMockUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";

// This contract implements the pre-4.5 UUPS upgrade function with a rollback test.
// It's used to test that newer UUPS contracts are considered valid upgrades by older UUPS contracts.
contract UUPSUpgradeableLegacyMockUpgradeable is UUPSUpgradeableMockUpgradeable {
    // ERC1967UpgradeUpgradeable._setImplementation is private so we reproduce it here.
    // An extra underscore prevents a name clash error.
    function __setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeToAndCallSecureLegacyV1(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        __setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting =
            StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            AddressUpgradeable.functionDelegateCall(
                newImplementation, abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
        }
    }

    // Hooking into the old mechanism
    function upgradeTo(address newImplementation) public override {
        _upgradeToAndCallSecureLegacyV1(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) public payable override {
        _upgradeToAndCallSecureLegacyV1(newImplementation, data, false);
    }
}
