// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/proxy/beacon/BeaconProxy.sol";
import "../../../src/proxy/beacon/UpgradeableBeacon.sol";
import "../../../src/mocks/DummyImplementation.sol";
import "../../../src/mocks/proxy/BadBeacon.sol";

contract BeaconProxyTest is Test {
    bytes32 private constant BEACON_SLOT =
        0x79d0e26f0ed6a26bf96d37944c615e11aedbfafe56e064339e13dad9525cda31;

    address private _anotherAccount;
    DummyImplementation private _implementationV0;
    DummyImplementationV2 private _implementationV1;

    function setUp() public {
        _anotherAccount = makeAddr("another");
        _implementationV0 = new DummyImplementation();
        _implementationV1 = new DummyImplementationV2();
    }

    function testBadBeaconNonContract() public {
        vm.expectRevert(bytes("ERC1967: new beacon is not a contract"));
        new BeaconProxy(_anotherAccount, "");
    }

    function testBadBeaconNoImplementation() public {
        BadBeaconNoImpl beacon = new BadBeaconNoImpl();
        vm.expectRevert();
        new BeaconProxy(address(beacon), "");
    }

    function testBadBeaconNotContract() public {
        BadBeaconNotContract beacon = new BadBeaconNotContract();
        vm.expectRevert(bytes("ERC1967: beacon implementation is not a contract"));
        new BeaconProxy(address(beacon), "");
    }

    function testNoInitialization() public {
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(_implementationV0));
        uint256 balance = 10;
        BeaconProxy proxy = new BeaconProxy{value: balance}(address(beacon), "");

        _assertInitialized(proxy, beacon, 0, balance);
    }

    function testNonPayableInitialization() public {
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(_implementationV0));
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 55);
        BeaconProxy proxy = new BeaconProxy(address(beacon), data);

        _assertInitialized(proxy, beacon, 55, 0);
    }

    function testPayableInitialization() public {
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(_implementationV0));
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 55);
        uint256 balance = 100;
        BeaconProxy proxy = new BeaconProxy{value: balance}(address(beacon), data);

        _assertInitialized(proxy, beacon, 55, balance);
    }

    function testRevertingInitialization() public {
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(_implementationV0));
        bytes memory data = abi.encodeWithSignature("reverts()");
        vm.expectRevert(bytes("DummyImplementation reverted"));
        new BeaconProxy(address(beacon), data);
    }

    function testUpgradeProxyByUpgradingBeacon() public {
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(_implementationV0));

        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        BeaconProxy proxy = new BeaconProxy(address(beacon), data);

        DummyImplementation dummy = DummyImplementation(address(proxy));
        assertEq(dummy.value(), 10);
        assertEq(dummy.version(), "V1");

        beacon.upgradeTo(address(_implementationV1));
        assertEq(dummy.version(), "V2");
    }

    function testUpgradeTwoProxiesByUpgradingBeacon() public {
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(_implementationV0));

        bytes memory data1 = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        BeaconProxy proxy1 = new BeaconProxy(address(beacon), data1);
        bytes memory data2 = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 42);
        BeaconProxy proxy2 = new BeaconProxy(address(beacon), data2);

        DummyImplementation dummy1 = DummyImplementation(address(proxy1));
        DummyImplementation dummy2 = DummyImplementation(address(proxy2));

        assertEq(dummy1.value(), 10);
        assertEq(dummy2.value(), 42);
        assertEq(dummy1.version(), "V1");
        assertEq(dummy2.version(), "V1");

        beacon.upgradeTo(address(_implementationV1));
        assertEq(dummy1.version(), "V2");
        assertEq(dummy2.version(), "V2");
    }

    function _assertInitialized(
        BeaconProxy proxy,
        UpgradeableBeacon beacon,
        uint256 value,
        uint256 balance
    ) private {
        bytes32 beaconSlot = vm.load(address(proxy), BEACON_SLOT);
        address beaconAddress = address(uint176(uint256(beaconSlot)));
        assertEq(beaconAddress, address(beacon));

        DummyImplementation dummy = DummyImplementation(address(proxy));
        assertEq(dummy.value(), value);
        assertEq(address(proxy).balance, balance);
    }
}
