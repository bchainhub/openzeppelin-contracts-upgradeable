// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/mocks/proxy/UpgradeableBeacon.sol";
import "../../../src/mocks/RegressionImplementationUpgradeable.sol";

contract UpgradeableBeaconUpgradeableTest is Test {
    address private _owner;
    address private _other;

    function setUp() public {
        _owner = makeAddr("owner");
        _other = makeAddr("other");
    }

    function testCannotCreateWithNonContractImplementation() public {
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock();
        vm.prank(_owner);
        vm.expectRevert(bytes("UpgradeableBeacon: implementation is not a contract"));
        beacon.initialize(_other);
    }

    function testReturnsImplementation() public {
        Implementation1Upgradeable v1 = new Implementation1Upgradeable();
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock();
        vm.prank(_owner);
        beacon.initialize(address(v1));
        assertEq(beacon.implementation(), address(v1));
    }

    function testUpgradeByOwner() public {
        Implementation1Upgradeable v1 = new Implementation1Upgradeable();
        Implementation2Upgradeable v2 = new Implementation2Upgradeable();
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock();
        vm.prank(_owner);
        beacon.initialize(address(v1));

        vm.prank(_owner);
        beacon.upgradeTo(address(v2));
        assertEq(beacon.implementation(), address(v2));
    }

    function testUpgradeToNonContractReverts() public {
        Implementation1Upgradeable v1 = new Implementation1Upgradeable();
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock();
        vm.prank(_owner);
        beacon.initialize(address(v1));

        vm.prank(_owner);
        vm.expectRevert(bytes("UpgradeableBeacon: implementation is not a contract"));
        beacon.upgradeTo(_other);
    }

    function testUpgradeByNonOwnerReverts() public {
        Implementation1Upgradeable v1 = new Implementation1Upgradeable();
        Implementation2Upgradeable v2 = new Implementation2Upgradeable();
        UpgradeableBeaconMock beacon = new UpgradeableBeaconMock();
        vm.prank(_owner);
        beacon.initialize(address(v1));

        vm.prank(_other);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        beacon.upgradeTo(address(v2));
    }
}
