// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/mocks/DummyImplementation.sol";
import "../../../src/proxy/transparent/ProxyAdmin.sol";
import "../../../src/proxy/transparent/TransparentUpgradeableProxy.sol";

contract ProxyAdminTest is Test {
    address private _proxyAdminOwner;
    address private _newAdmin;
    address private _anotherAccount;

    DummyImplementation private _implementationV1;
    DummyImplementationV2 private _implementationV2;
    ProxyAdmin private _proxyAdmin;
    ITransparentUpgradeableProxy private _proxy;

    function setUp() public {
        _proxyAdminOwner = makeAddr("proxyAdminOwner");
        _newAdmin = makeAddr("newAdmin");
        _anotherAccount = makeAddr("anotherAccount");

        _implementationV1 = new DummyImplementation();
        _implementationV2 = new DummyImplementationV2();

        vm.prank(_proxyAdminOwner);
        _proxyAdmin = new ProxyAdmin();

        vm.prank(_proxyAdminOwner);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(_implementationV1),
            address(_proxyAdmin),
            ""
        );
        _proxy = ITransparentUpgradeableProxy(address(proxy));
    }

    function testHasOwner() public {
        assertEq(_proxyAdmin.owner(), _proxyAdminOwner);
    }

    function testGetProxyAdmin() public {
        address admin = _proxyAdmin.getProxyAdmin(_proxy);
        assertEq(admin, address(_proxyAdmin));
    }

    function testGetProxyAdminInvalidProxyReverts() public {
        vm.expectRevert();
        _proxyAdmin.getProxyAdmin(ITransparentUpgradeableProxy(address(_implementationV1)));
    }

    function testChangeProxyAdminUnauthorizedReverts() public {
        vm.prank(_anotherAccount);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        _proxyAdmin.changeProxyAdmin(_proxy, _newAdmin);
    }

    function testChangeProxyAdmin() public {
        vm.prank(_proxyAdminOwner);
        _proxyAdmin.changeProxyAdmin(_proxy, _newAdmin);

        vm.prank(_newAdmin);
        address admin = _proxy.admin();
        assertEq(admin, _newAdmin);
    }

    function testGetProxyImplementation() public {
        address implementationAddress = _proxyAdmin.getProxyImplementation(_proxy);
        assertEq(implementationAddress, address(_implementationV1));
    }

    function testGetProxyImplementationInvalidProxyReverts() public {
        vm.expectRevert();
        _proxyAdmin.getProxyImplementation(ITransparentUpgradeableProxy(address(_implementationV1)));
    }

    function testUpgradeUnauthorizedReverts() public {
        vm.prank(_anotherAccount);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        _proxyAdmin.upgrade(_proxy, address(_implementationV2));
    }

    function testUpgrade() public {
        vm.prank(_proxyAdminOwner);
        _proxyAdmin.upgrade(_proxy, address(_implementationV2));
        address implementationAddress = _proxyAdmin.getProxyImplementation(_proxy);
        assertEq(implementationAddress, address(_implementationV2));
    }

    function testUpgradeAndCallUnauthorizedReverts() public {
        bytes memory callData = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 1337);
        vm.prank(_anotherAccount);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        _proxyAdmin.upgradeAndCall(_proxy, address(_implementationV2), callData);
    }

    function testUpgradeAndCallInvalidDataReverts() public {
        bytes memory callData = hex"12345678";
        vm.prank(_proxyAdminOwner);
        vm.expectRevert();
        _proxyAdmin.upgradeAndCall(_proxy, address(_implementationV2), callData);
    }

    function testUpgradeAndCallValidData() public {
        bytes memory callData = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 1337);
        vm.prank(_proxyAdminOwner);
        _proxyAdmin.upgradeAndCall(_proxy, address(_implementationV2), callData);
        address implementationAddress = _proxyAdmin.getProxyImplementation(_proxy);
        assertEq(implementationAddress, address(_implementationV2));
    }
}
