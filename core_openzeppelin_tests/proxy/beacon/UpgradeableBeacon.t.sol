// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/proxy/beacon/UpgradeableBeacon.sol";
import "../../../src/mocks/RegressionImplementation.sol";

contract UpgradeableBeaconTest is Test {
    address private _owner;
    address private _other;

    function setUp() public {
        _owner = makeAddr("owner");
        _other = makeAddr("other");
    }

    function testCannotCreateWithNonContractImplementation() public {
        vm.expectRevert(bytes("UpgradeableBeacon: implementation is not a contract"));
        new UpgradeableBeacon(_other);
    }

    function testReturnsImplementation() public {
        Implementation1 v1 = new Implementation1();
        vm.prank(_owner);
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(v1));
        assertEq(beacon.implementation(), address(v1));
    }

    function testUpgradeByOwner() public {
        Implementation1 v1 = new Implementation1();
        Implementation2 v2 = new Implementation2();
        vm.prank(_owner);
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(v1));

        vm.prank(_owner);
        beacon.upgradeTo(address(v2));
        assertEq(beacon.implementation(), address(v2));
    }

    function testUpgradeToNonContractReverts() public {
        Implementation1 v1 = new Implementation1();
        vm.prank(_owner);
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(v1));

        vm.prank(_owner);
        vm.expectRevert(bytes("UpgradeableBeacon: implementation is not a contract"));
        beacon.upgradeTo(_other);
    }

    function testUpgradeByNonOwnerReverts() public {
        Implementation1 v1 = new Implementation1();
        Implementation2 v2 = new Implementation2();
        vm.prank(_owner);
        UpgradeableBeacon beacon = new UpgradeableBeacon(address(v1));

        vm.prank(_other);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        beacon.upgradeTo(address(v2));
    }
}
