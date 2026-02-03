// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "./ERC1967Proxy.sol";
import "./ITransparentUpgradeableProxy.sol";

contract TransparentUpgradeableProxyMock is ERC1967ProxyMock {
    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967ProxyMock(_logic, _data) {
        _changeAdmin(admin_);
    }

    function _fallback() internal virtual override {
        if (msg.sender == _getAdmin()) {
            bytes memory ret;
            bytes4 selector = msg.sig;
            if (selector == ITransparentUpgradeableProxyMock.upgradeTo.selector) {
                ret = _dispatchUpgradeTo();
            } else if (selector == ITransparentUpgradeableProxyMock.upgradeToAndCall.selector) {
                ret = _dispatchUpgradeToAndCall();
            } else if (selector == ITransparentUpgradeableProxyMock.changeAdmin.selector) {
                ret = _dispatchChangeAdmin();
            } else if (selector == ITransparentUpgradeableProxyMock.admin.selector) {
                ret = _dispatchAdmin();
            } else if (selector == ITransparentUpgradeableProxyMock.implementation.selector) {
                ret = _dispatchImplementation();
            } else {
                revert("TransparentUpgradeableProxy: admin cannot fallback to proxy target");
            }
            assembly {
                return(add(ret, 0x20), mload(ret))
            }
        } else {
            super._fallback();
        }
    }

    function _dispatchAdmin() private returns (bytes memory) {
        _requireZeroValue();
        return abi.encode(_getAdmin());
    }

    function _dispatchImplementation() private returns (bytes memory) {
        _requireZeroValue();
        return abi.encode(_implementation());
    }

    function _dispatchChangeAdmin() private returns (bytes memory) {
        _requireZeroValue();
        address newAdmin = abi.decode(msg.data[4:], (address));
        _changeAdmin(newAdmin);
        return "";
    }

    function _dispatchUpgradeTo() private returns (bytes memory) {
        _requireZeroValue();
        address newImplementation = abi.decode(msg.data[4:], (address));
        _upgradeToAndCall(newImplementation, bytes(""), false);
        return "";
    }

    function _dispatchUpgradeToAndCall() private returns (bytes memory) {
        (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
        _upgradeToAndCall(newImplementation, data, true);
        return "";
    }

    function _requireZeroValue() private {
        require(msg.value == 0);
    }
}
