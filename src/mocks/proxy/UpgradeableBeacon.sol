// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../../proxy/beacon/IBeaconUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../access/OwnableUpgradeable.sol";

contract UpgradeableBeaconMock is IBeaconUpgradeable, OwnableUpgradeable {
    address private _implementation;

    event Upgraded(address indexed implementation);

    function initialize(address implementation_) external initializer {
        __Ownable_init();
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}
