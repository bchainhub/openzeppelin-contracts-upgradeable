// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/access/OwnableUpgradeable.sol";
import "../../src/utils/ChecksumUpgradeable.sol";

contract OwnableUpgradeableHarness is OwnableUpgradeable {
    function initialize() external initializer {
        __Ownable_init();
    }

    function transferOwnershipInternal(address newOwner) external {
        _transferOwnership(newOwner);
    }
}

contract OwnableUpgradeableTest is Test {
    OwnableUpgradeableHarness private _ownable;
    address private _owner;
    address private _other;

    function setUp() public {
        _owner = makeAddr("owner");
        _other = makeAddr("other");

        _ownable = new OwnableUpgradeableHarness();
        vm.prank(_owner);
        _ownable.initialize();
    }

    function testHasOwner() public {
        assertEq(_ownable.owner(), _owner);
    }

    function testTransferOwnershipChangesOwner() public {
        vm.prank(_owner);
        _ownable.transferOwnership(_other);
        assertEq(_ownable.owner(), _other);
    }

    function testTransferOwnershipRejectsNonOwner() public {
        vm.prank(_other);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        _ownable.transferOwnership(_other);
    }

    function testTransferOwnershipRejectsZeroAddress() public {
        vm.prank(_owner);
        vm.expectRevert(bytes("Ownable: new owner is the zero address"));
        _ownable.transferOwnership(address(0));
    }

    function testTransferOwnershipRejectsChecksumZeroAddress() public {
        vm.prank(_owner);
        vm.expectRevert(bytes("Ownable: new owner is the zero address"));
        _ownable.transferOwnership(ChecksumUpgradeable.zeroAddress());
    }

    function testRenounceOwnership() public {
        vm.prank(_owner);
        _ownable.renounceOwnership();
        assertEq(_ownable.owner(), address(0));
    }

    function testRenounceOwnershipRejectsNonOwner() public {
        vm.prank(_other);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        _ownable.renounceOwnership();
    }

    function testTransferOwnershipInternalAfterRenounce() public {
        vm.prank(_owner);
        _ownable.renounceOwnership();

        _ownable.transferOwnershipInternal(_other);
        assertEq(_ownable.owner(), _other);
    }
}
