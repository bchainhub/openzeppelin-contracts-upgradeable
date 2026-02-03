// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "./ITransparentUpgradeableProxy.sol";

contract ProxyAdminMock {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getProxyImplementation(ITransparentUpgradeableProxyMock proxy) public view virtual returns (address) {
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f5d97006");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(ITransparentUpgradeableProxyMock proxy) public view virtual returns (address) {
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"eb8325fb");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(ITransparentUpgradeableProxyMock proxy, address newAdmin) public virtual onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    function upgrade(ITransparentUpgradeableProxyMock proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(
        ITransparentUpgradeableProxyMock proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}
