// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/ChecksumUpgradeable.sol";

contract ChecksumUpgradeableHarness {
    function zeroAddress() external view returns (address) {
        return ChecksumUpgradeable.zeroAddress();
    }

    function isValid(address addr) external pure returns (bool) {
        return ChecksumUpgradeable.isValid(addr);
    }

    function toIcan(uint160 rawAddress) external view returns (address) {
        return ChecksumUpgradeable.toIcan(rawAddress);
    }
}

contract ChecksumUpgradeableTest is Test {
    ChecksumUpgradeableHarness private _harness;

    function setUp() public {
        _harness = new ChecksumUpgradeableHarness();
    }

    function testZeroAddressMainnetChainId1() public {
        vm.chainId(1);

        address expected = address(0xcb540000000000000000000000000000000000000000);
        assertEq(_harness.zeroAddress(), expected);
        assertEq(_harness.isValid(expected), true);
    }

    function testZeroAddressDevinChainId3() public {
        vm.chainId(3);
        address expected = address(0xab720000000000000000000000000000000000000000);
        assertEq(_harness.zeroAddress(), expected);
        assertEq(_harness.isValid(expected), true);
    }

    function testZeroAddressChainId57() public {
        vm.chainId(57);

        address expected = address(0xce450000000000000000000000000000000000000000);
        assertEq(_harness.zeroAddress(), expected);
        assertEq(_harness.isValid(expected), true);
    }

    function testPredefinedAddressChainId57() public {
        vm.chainId(57);

        uint160 t1 = uint160(uint176(address(0x001720e1498b1bb801f57ccbf3ee34514c5cc48f91c4)));
        address t2 = _harness.toIcan(t1);
        assertEq(t2, address(0xce9320e1498b1bb801f57ccbf3ee34514c5cc48f91c4));
    }

    function testZeroAddressAllZerosIsInvalid() public {
        address allZero = address(0);
        assertEq(_harness.isValid(allZero), false);
    }
}
