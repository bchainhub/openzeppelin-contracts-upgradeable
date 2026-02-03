// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../../../src/interfaces/IERC1967.sol";
import "../../../src/mocks/DummyImplementation.sol";
import "../../../src/mocks/InitializableMock.sol";
import "../../../src/mocks/SingleInheritanceInitializableMocks.sol";
import "../../../src/mocks/RegressionImplementation.sol";
import "../../../src/mocks/proxy/ClashingImplementation.sol";

contract TransparentUpgradeableProxyTest is Test {
    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant IMPLEMENTATION_SLOT =
        0x169aa7877a62aec264f92a4c78812101abc42f65cbb20781a5cb4084c2d639d7;
    bytes32 private constant ADMIN_SLOT =
        0x5846d050da0e75d43b6055ae3cd6c2c65e1941ccb45afff84b891ff0c7a8e50e;

    address private _proxyAdminAddress;
    address private _proxyAdminOwner;
    address private _anotherAccount;

    address private _implementationV0;
    address private _implementationV1;

    ITransparentUpgradeableProxy private _proxy;
    address private _proxyAddress;

    function setUp() public {
        _proxyAdminAddress = makeAddr("proxyAdmin");
        _proxyAdminOwner = makeAddr("proxyAdminOwner");
        _anotherAccount = makeAddr("another");

        _implementationV0 = address(new DummyImplementation());
        _implementationV1 = address(new DummyImplementation());

        _proxy = _createProxy(_implementationV0, _proxyAdminAddress, "");
        _proxyAddress = address(_proxy);
    }

    function testImplementationReturnsCurrentImplementation() public {
        vm.prank(_proxyAdminAddress);
        address implementation = _proxy.implementation();
        assertEq(implementation, _implementationV0);
    }

    function testDelegatesToImplementation() public {
        DummyImplementation dummy = DummyImplementation(_proxyAddress);
        vm.prank(_anotherAccount);
        bool value = dummy.get();
        assertTrue(value);
    }

    function testUpgradeToByAdmin() public {
        vm.prank(_proxyAdminAddress);
        _proxy.upgradeTo(_implementationV1);

        vm.prank(_proxyAdminAddress);
        address implementation = _proxy.implementation();
        assertEq(implementation, _implementationV1);
    }

    function testUpgradeToEmitsEvent() public {
        vm.prank(_proxyAdminAddress);
        vm.expectEmit(true, false, false, true);
        emit Upgraded(_implementationV1);
        _proxy.upgradeTo(_implementationV1);
    }

    function testUpgradeToZeroAddressReverts() public {
        vm.prank(_proxyAdminAddress);
        vm.expectRevert(bytes("ERC1967: new implementation is not a contract"));
        _proxy.upgradeTo(address(0));
    }

    function testUpgradeToByNonAdminReverts() public {
        vm.prank(_anotherAccount);
        vm.expectRevert();
        _proxy.upgradeTo(_implementationV1);
    }

    function testUpgradeToAndCallInitializable() public {
        InitializableMock behavior = new InitializableMock();
        bytes memory initializeData = abi.encodeWithSignature("initializeWithX(uint256)", 42);
        uint256 value = 1e5;
        vm.deal(_proxyAdminAddress, value);

        vm.prank(_proxyAdminAddress);
        _proxy.upgradeToAndCall{value: value}(address(behavior), initializeData);

        vm.prank(_proxyAdminAddress);
        address implementation = _proxy.implementation();
        assertEq(implementation, address(behavior));

        InitializableMock migratable = InitializableMock(_proxyAddress);
        assertEq(migratable.x(), 42);
        assertEq(_proxyAddress.balance, value);

        bytes32 stored = vm.load(_proxyAddress, bytes32(uint256(1)));
        assertEq(uint256(stored), 42);
    }

    function testUpgradeToAndCallByNonAdminReverts() public {
        InitializableMock behavior = new InitializableMock();
        bytes memory initializeData = abi.encodeWithSignature("initializeWithX(uint256)", 42);

        vm.prank(_anotherAccount);
        vm.expectRevert();
        _proxy.upgradeToAndCall(address(behavior), initializeData);
    }

    function testUpgradeToAndCallFailReverts() public {
        InitializableMock behavior = new InitializableMock();
        bytes memory initializeData = abi.encodeWithSignature("fail()");

        vm.prank(_proxyAdminAddress);
        vm.expectRevert();
        _proxy.upgradeToAndCall(address(behavior), initializeData);
    }

    function testMigrationsV1V2V3() public {
        uint256 value = 1e5;
        vm.deal(_proxyAdminAddress, value * 3);

        MigratableMockV1 behaviorV1 = new MigratableMockV1();
        bytes memory v1Data = abi.encodeWithSignature("initialize(uint256)", 42);
        uint256 balancePrevV1 = _proxyAddress.balance;

        vm.prank(_proxyAdminAddress);
        _proxy.upgradeToAndCall{value: value}(address(behaviorV1), v1Data);

        MigratableMockV1 migratableV1 = MigratableMockV1(_proxyAddress);
        assertEq(migratableV1.x(), 42);
        assertEq(_proxyAddress.balance, balancePrevV1 + value);

        MigratableMockV2 behaviorV2 = new MigratableMockV2();
        bytes memory v2Data = abi.encodeWithSignature("migrate(uint256,uint256)", 10, 42);
        uint256 balancePrevV2 = _proxyAddress.balance;

        vm.prank(_proxyAdminAddress);
        _proxy.upgradeToAndCall{value: value}(address(behaviorV2), v2Data);

        MigratableMockV2 migratableV2 = MigratableMockV2(_proxyAddress);
        assertEq(migratableV2.x(), 10);
        assertEq(migratableV2.y(), 42);
        assertEq(_proxyAddress.balance, balancePrevV2 + value);

        MigratableMockV3 behaviorV3 = new MigratableMockV3();
        bytes memory v3Data = abi.encodeWithSignature("migrate()");
        uint256 balancePrevV3 = _proxyAddress.balance;

        vm.prank(_proxyAdminAddress);
        _proxy.upgradeToAndCall{value: value}(address(behaviorV3), v3Data);

        MigratableMockV3 migratableV3 = MigratableMockV3(_proxyAddress);
        assertEq(migratableV3.x(), 42);
        assertEq(migratableV3.y(), 10);
        assertEq(_proxyAddress.balance, balancePrevV3 + value);
    }

    function testUpgradeToAndCallMigrationsByNonAdminReverts() public {
        MigratableMockV1 behaviorV1 = new MigratableMockV1();
        bytes memory v1Data = abi.encodeWithSignature("initialize(uint256)", 42);

        vm.prank(_anotherAccount);
        vm.expectRevert();
        _proxy.upgradeToAndCall(address(behaviorV1), v1Data);
    }

    function testChangeAdmin() public {
        vm.prank(_proxyAdminAddress);
        vm.expectEmit(true, true, false, true);
        emit AdminChanged(_proxyAdminAddress, _anotherAccount);
        _proxy.changeAdmin(_anotherAccount);

        vm.prank(_anotherAccount);
        address newAdmin = _proxy.admin();
        assertEq(newAdmin, _anotherAccount);
    }

    function testChangeAdminByNonAdminReverts() public {
        vm.prank(_anotherAccount);
        vm.expectRevert();
        _proxy.changeAdmin(_anotherAccount);
    }

    function testChangeAdminZeroAddressReverts() public {
        vm.prank(_proxyAdminAddress);
        vm.expectRevert(bytes("ERC1967: new admin is the zero address"));
        _proxy.changeAdmin(address(0));
    }

    function testStorageSlots() public {
        bytes32 implRaw = vm.load(_proxyAddress, IMPLEMENTATION_SLOT);
        address impl = address(uint176(uint256(implRaw)));
        assertEq(impl, _implementationV0);

        bytes32 adminRaw = vm.load(_proxyAddress, ADMIN_SLOT);
        address admin = address(uint176(uint256(adminRaw)));
        assertEq(admin, _proxyAdminAddress);
    }

    function testTransparentProxyAdminCannotFallback() public {
        ClashingImplementation impl = new ClashingImplementation();
        ITransparentUpgradeableProxy proxy = _createProxy(address(impl), _proxyAdminAddress, "");

        vm.prank(_proxyAdminAddress);
        vm.expectRevert(bytes("TransparentUpgradeableProxy: admin cannot fallback to proxy target"));
        ClashingImplementation(address(proxy)).delegatedFunction();
    }

    function testClashAdminAsProxyAdmin() public {
        ClashingImplementation impl = new ClashingImplementation();
        ITransparentUpgradeableProxy proxy = _createProxy(address(impl), _proxyAdminAddress, "");

        vm.prank(_proxyAdminAddress);
        address value = proxy.admin();
        assertEq(value, _proxyAdminAddress);
    }

    function testClashAdminAsOther() public {
        ClashingImplementation impl = new ClashingImplementation();
        ITransparentUpgradeableProxy proxy = _createProxy(address(impl), _proxyAdminAddress, "");

        vm.prank(_anotherAccount);
        address value = ClashingImplementation(address(proxy)).admin();
        assertEq(value, address(uint176(0x0000000000000000000000000000000011111142)));
    }

    function testClashAdminValueAsProxyAdminReverts() public {
        ClashingImplementation impl = new ClashingImplementation();
        ITransparentUpgradeableProxy proxy = _createProxy(address(impl), _proxyAdminAddress, "");

        vm.deal(_proxyAdminAddress, 1);
        vm.prank(_proxyAdminAddress);
        (bool ok,) = address(proxy).call{value: 1}(abi.encodeWithSignature("admin()"));
        assertFalse(ok);
    }

    function testClashAdminValueAsOtherSucceeds() public {
        ClashingImplementation impl = new ClashingImplementation();
        ITransparentUpgradeableProxy proxy = _createProxy(address(impl), _proxyAdminAddress, "");

        vm.deal(_anotherAccount, 1);
        vm.prank(_anotherAccount);
        (bool ok, bytes memory data) = address(proxy).call{value: 1}(abi.encodeWithSignature("admin()"));
        assertTrue(ok);
        address value = abi.decode(data, (address));
        assertEq(value, address(uint176(0x0000000000000000000000000000000011111142)));
    }

    function testRegressionAddFunction() public {
        Implementation1 instance1 = new Implementation1();
        ITransparentUpgradeableProxy proxy = _createProxy(address(instance1), _proxyAdminAddress, "");

        Implementation1 proxyInstance1 = Implementation1(address(proxy));
        vm.prank(_anotherAccount);
        proxyInstance1.setValue(42);

        Implementation2 instance2 = new Implementation2();
        vm.prank(_proxyAdminAddress);
        proxy.upgradeTo(address(instance2));

        Implementation2 proxyInstance2 = Implementation2(address(proxy));
        vm.prank(_anotherAccount);
        uint256 res = proxyInstance2.getValue();
        assertEq(res, 42);
    }

    function testRegressionRemoveFunction() public {
        Implementation2 instance2 = new Implementation2();
        ITransparentUpgradeableProxy proxy = _createProxy(address(instance2), _proxyAdminAddress, "");

        Implementation2 proxyInstance2 = Implementation2(address(proxy));
        vm.prank(_anotherAccount);
        proxyInstance2.setValue(42);
        vm.prank(_anotherAccount);
        uint256 res = proxyInstance2.getValue();
        assertEq(res, 42);

        Implementation1 instance1 = new Implementation1();
        vm.prank(_proxyAdminAddress);
        proxy.upgradeTo(address(instance1));

        Implementation2 proxyInstance1 = Implementation2(address(proxy));
        vm.prank(_anotherAccount);
        vm.expectRevert();
        proxyInstance1.getValue();
    }

    function testRegressionChangeSignature() public {
        Implementation1 instance1 = new Implementation1();
        ITransparentUpgradeableProxy proxy = _createProxy(address(instance1), _proxyAdminAddress, "");

        Implementation1 proxyInstance1 = Implementation1(address(proxy));
        vm.prank(_anotherAccount);
        proxyInstance1.setValue(42);

        Implementation3 instance3 = new Implementation3();
        vm.prank(_proxyAdminAddress);
        proxy.upgradeTo(address(instance3));

        Implementation3 proxyInstance3 = Implementation3(address(proxy));
        vm.prank(_anotherAccount);
        uint256 res = proxyInstance3.getValue(8);
        assertEq(res, 50);
    }

    function testRegressionAddFallbackFunction() public {
        Implementation1 instance1 = new Implementation1();
        ITransparentUpgradeableProxy proxy = _createProxy(address(instance1), _proxyAdminAddress, "");

        Implementation4 instance4 = new Implementation4();
        vm.prank(_proxyAdminAddress);
        proxy.upgradeTo(address(instance4));

        vm.prank(_anotherAccount);
        (bool ok,) = address(proxy).call("");
        assertTrue(ok);

        Implementation4 proxyInstance4 = Implementation4(address(proxy));
        vm.prank(_anotherAccount);
        uint256 res = proxyInstance4.getValue();
        assertEq(res, 1);
    }

    function testRegressionRemoveFallbackFunction() public {
        Implementation4 instance4 = new Implementation4();
        ITransparentUpgradeableProxy proxy = _createProxy(address(instance4), _proxyAdminAddress, "");

        Implementation2 instance2 = new Implementation2();
        vm.prank(_proxyAdminAddress);
        proxy.upgradeTo(address(instance2));

        vm.prank(_anotherAccount);
        (bool ok,) = address(proxy).call("");
        assertFalse(ok);

        Implementation2 proxyInstance2 = Implementation2(address(proxy));
        vm.prank(_anotherAccount);
        uint256 res = proxyInstance2.getValue();
        assertEq(res, 0);
    }

    function _createProxy(
        address logic,
        address admin,
        bytes memory initData
    ) private returns (ITransparentUpgradeableProxy) {
        vm.prank(_proxyAdminOwner);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(logic, admin, initData);
        return ITransparentUpgradeableProxy(address(proxy));
    }
}
