// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/mocks/proxy/BeaconProxy.sol";
import "../../../src/mocks/proxy/UpgradeableBeacon.sol";
import "../../../src/mocks/DummyImplementation.sol";
import "../../../src/mocks/proxy/BadBeacon.sol";

contract BeaconProxyUpgradeableTest is Test {
    bytes32 private constant BEACON_SLOT =
        0x79d0e26f0ed6a26bf96d37944c615e11aedbfafe56e064339e13dad9525cda31;

    address private _anotherAccount;
    DummyImplementationUpgradeable private _implementationV0;
    DummyImplementationV2Upgradeable private _implementationV1;

    function setUp() public {
        _anotherAccount = makeAddr("another");
        _implementationV0 = new DummyImplementationUpgradeable();
        _implementationV1 = new DummyImplementationV2Upgradeable();
    }

    function testBadBeaconNonContract() public {
        vm.expectRevert(bytes("ERC1967: new beacon is not a contract"));
        new BeaconProxyMock(_anotherAccount, "");
    }

    function testBadBeaconNoImplementation() public {
        BadBeaconNoImplUpgradeable beacon = new BadBeaconNoImplUpgradeable();
        vm.expectRevert();
        new BeaconProxyMock(address(beacon), "");
    }

    function testBadBeaconNotContract() public {
        BadBeaconNotContractUpgradeable beacon = new BadBeaconNotContractUpgradeable();
        vm.expectRevert(bytes("ERC1967: beacon implementation is not a contract"));
        new BeaconProxyMock(address(beacon), "");
    }

    function testNoInitialization() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock(address(_implementationV0));
        uint256 balance = 10;
        BeaconProxyMock proxy = new BeaconProxyMock{value: balance}(address(beacon), "");

        _assertInitialized(proxy, beacon, 0, balance);
    }

    function testNonPayableInitialization() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock(address(_implementationV0));
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 55);
        BeaconProxyMock proxy = new BeaconProxyMock(address(beacon), data);

        _assertInitialized(proxy, beacon, 55, 0);
    }

    function testPayableInitialization() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock(address(_implementationV0));
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 55);
        uint256 balance = 100;
        BeaconProxyMock proxy = new BeaconProxyMock{value: balance}(address(beacon), data);

        _assertInitialized(proxy, beacon, 55, balance);
    }

    function testRevertingInitialization() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock(address(_implementationV0));
        bytes memory data = abi.encodeWithSignature("reverts()");
        vm.expectRevert(bytes("DummyImplementation reverted"));
        new BeaconProxyMock(address(beacon), data);
    }

    function testUpgradeProxyByUpgradingBeacon() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock(address(_implementationV0));

        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        BeaconProxyMock proxy = new BeaconProxyMock(address(beacon), data);

        DummyImplementationUpgradeable dummy = DummyImplementationUpgradeable(address(proxy));
        assertEq(dummy.value(), 10);
        assertEq(dummy.version(), "V1");

        beacon.upgradeTo(address(_implementationV1));
        assertEq(dummy.version(), "V2");
    }

    function testUpgradeTwoProxiesByUpgradingBeacon() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock(address(_implementationV0));

        bytes memory data1 = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        BeaconProxyMock proxy1 = new BeaconProxyMock(address(beacon), data1);
        bytes memory data2 = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 42);
        BeaconProxyMock proxy2 = new BeaconProxyMock(address(beacon), data2);

        DummyImplementationUpgradeable dummy1 = DummyImplementationUpgradeable(address(proxy1));
        DummyImplementationUpgradeable dummy2 = DummyImplementationUpgradeable(address(proxy2));

        assertEq(dummy1.value(), 10);
        assertEq(dummy2.value(), 42);
        assertEq(dummy1.version(), "V1");
        assertEq(dummy2.version(), "V1");

        beacon.upgradeTo(address(_implementationV1));
        assertEq(dummy1.version(), "V2");
        assertEq(dummy2.version(), "V2");
    }

    function _assertInitialized(
        BeaconProxyMock proxy,
        UpgradeableBeaconMock beacon,
        uint256 value,
        uint256 balance
    ) private {
        bytes32 beaconSlot = vm.load(address(proxy), BEACON_SLOT);
        address beaconAddress = address(uint176(uint256(beaconSlot)));
        assertEq(beaconAddress, address(beacon));

        DummyImplementationUpgradeable dummy = DummyImplementationUpgradeable(address(proxy));
        assertEq(dummy.value(), value);
        assertEq(address(proxy).balance, balance);
    }
}
