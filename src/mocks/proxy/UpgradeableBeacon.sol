// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../../proxy/beacon/IBeaconUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

contract UpgradeableBeaconMock is IBeaconUpgradeable {
    address private _owner;
    address private _implementation;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Upgraded(address indexed implementation);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(address implementation_) {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        _setImplementation(implementation_);
    }

    function owner() public view returns (address) {
        return _owner;
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
