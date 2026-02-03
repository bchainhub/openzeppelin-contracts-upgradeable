// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/math/MathUpgradeable.sol";

contract MathUpgradeableHarness {
    function max(uint256 a, uint256 b) external pure returns (uint256) {
        return MathUpgradeable.max(a, b);
    }

    function min(uint256 a, uint256 b) external pure returns (uint256) {
        return MathUpgradeable.min(a, b);
    }

    function average(uint256 a, uint256 b) external pure returns (uint256) {
        return MathUpgradeable.average(a, b);
    }

    function ceilDiv(uint256 a, uint256 b) external pure returns (uint256) {
        return MathUpgradeable.ceilDiv(a, b);
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        MathUpgradeable.Rounding rounding
    ) external pure returns (uint256) {
        return MathUpgradeable.mulDiv(x, y, denominator, rounding);
    }

    function sqrt(uint256 a, MathUpgradeable.Rounding rounding) external pure returns (uint256) {
        return MathUpgradeable.sqrt(a, rounding);
    }

    function log2(uint256 value, MathUpgradeable.Rounding rounding) external pure returns (uint256) {
        return MathUpgradeable.log2(value, rounding);
    }

    function log10(uint256 value, MathUpgradeable.Rounding rounding) external pure returns (uint256) {
        return MathUpgradeable.log10(value, rounding);
    }

    function log256(uint256 value, MathUpgradeable.Rounding rounding) external pure returns (uint256) {
        return MathUpgradeable.log256(value, rounding);
    }
}

contract MathUpgradeableTest is Test {
    MathUpgradeableHarness private _math;

    function setUp() public {
        _math = new MathUpgradeableHarness();
    }

    function testMax() public {
        assertEq(_math.max(5678, 1234), 5678);
        assertEq(_math.max(1234, 5678), 5678);
    }

    function testMin() public {
        assertEq(_math.min(1234, 5678), 1234);
        assertEq(_math.min(5678, 1234), 1234);
    }

    function testAverage() public {
        assertEq(_math.average(57417, 95431), (57417 + 95431) / 2);
        assertEq(_math.average(42304, 84346), (42304 + 84346) / 2);
        assertEq(_math.average(type(uint256).max, type(uint256).max), type(uint256).max);
    }

    function testCeilDiv() public {
        assertEq(_math.ceilDiv(10, 5), 2);
        assertEq(_math.ceilDiv(42, 13), 4);
        assertEq(_math.ceilDiv(type(uint256).max, 2), uint256(1) << 255);
        assertEq(_math.ceilDiv(type(uint256).max, 1), type(uint256).max);
    }

    function testMulDivRevertsOnZeroDenominator() public {
        vm.expectRevert();
        _math.mulDiv(1, 1, 0, MathUpgradeable.Rounding.Down);
    }

    function testMulDivRoundsDownSmall() public {
        assertEq(_math.mulDiv(3, 4, 5, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.mulDiv(3, 5, 5, MathUpgradeable.Rounding.Down), 3);
    }

    function testMulDivRoundsDownLarge() public {
        uint256 max = type(uint256).max;
        uint256 maxSub1 = max - 1;
        uint256 maxSub2 = max - 2;
        assertEq(_math.mulDiv(42, maxSub1, max, MathUpgradeable.Rounding.Down), 41);
        assertEq(_math.mulDiv(17, max, max, MathUpgradeable.Rounding.Down), 17);
        assertEq(_math.mulDiv(maxSub1, maxSub1, max, MathUpgradeable.Rounding.Down), maxSub2);
        assertEq(_math.mulDiv(max, maxSub1, max, MathUpgradeable.Rounding.Down), maxSub1);
        assertEq(_math.mulDiv(max, max, max, MathUpgradeable.Rounding.Down), max);
    }

    function testMulDivRoundsUpSmall() public {
        assertEq(_math.mulDiv(3, 4, 5, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.mulDiv(3, 5, 5, MathUpgradeable.Rounding.Up), 3);
    }

    function testMulDivRoundsUpLarge() public {
        uint256 max = type(uint256).max;
        uint256 maxSub1 = max - 1;
        assertEq(_math.mulDiv(42, maxSub1, max, MathUpgradeable.Rounding.Up), 42);
        assertEq(_math.mulDiv(17, max, max, MathUpgradeable.Rounding.Up), 17);
        assertEq(_math.mulDiv(maxSub1, maxSub1, max, MathUpgradeable.Rounding.Up), maxSub1);
        assertEq(_math.mulDiv(max, maxSub1, max, MathUpgradeable.Rounding.Up), maxSub1);
        assertEq(_math.mulDiv(max, max, max, MathUpgradeable.Rounding.Up), max);
    }

    function testSqrtRoundsDown() public {
        assertEq(_math.sqrt(0, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.sqrt(1, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.sqrt(2, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.sqrt(3, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.sqrt(4, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.sqrt(144, MathUpgradeable.Rounding.Down), 12);
        assertEq(_math.sqrt(999999, MathUpgradeable.Rounding.Down), 999);
        assertEq(_math.sqrt(1000000, MathUpgradeable.Rounding.Down), 1000);
        assertEq(_math.sqrt(1000001, MathUpgradeable.Rounding.Down), 1000);
        assertEq(_math.sqrt(1002000, MathUpgradeable.Rounding.Down), 1000);
        assertEq(_math.sqrt(1002001, MathUpgradeable.Rounding.Down), 1001);
        assertEq(
            _math.sqrt(type(uint256).max, MathUpgradeable.Rounding.Down),
            340282366920938463463374607431768211455
        );
    }

    function testSqrtRoundsUp() public {
        assertEq(_math.sqrt(0, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.sqrt(1, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.sqrt(2, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.sqrt(3, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.sqrt(4, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.sqrt(144, MathUpgradeable.Rounding.Up), 12);
        assertEq(_math.sqrt(999999, MathUpgradeable.Rounding.Up), 1000);
        assertEq(_math.sqrt(1000000, MathUpgradeable.Rounding.Up), 1000);
        assertEq(_math.sqrt(1000001, MathUpgradeable.Rounding.Up), 1001);
        assertEq(_math.sqrt(1002000, MathUpgradeable.Rounding.Up), 1001);
        assertEq(_math.sqrt(1002001, MathUpgradeable.Rounding.Up), 1001);
        assertEq(
            _math.sqrt(type(uint256).max, MathUpgradeable.Rounding.Up),
            340282366920938463463374607431768211456
        );
    }

    function testLog2RoundsDown() public {
        assertEq(_math.log2(0, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log2(1, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log2(2, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log2(3, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log2(4, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log2(5, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log2(6, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log2(7, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log2(8, MathUpgradeable.Rounding.Down), 3);
        assertEq(_math.log2(9, MathUpgradeable.Rounding.Down), 3);
        assertEq(_math.log2(type(uint256).max, MathUpgradeable.Rounding.Down), 255);
    }

    function testLog2RoundsUp() public {
        assertEq(_math.log2(0, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.log2(1, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.log2(2, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log2(3, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log2(4, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log2(5, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log2(6, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log2(7, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log2(8, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log2(9, MathUpgradeable.Rounding.Up), 4);
        assertEq(_math.log2(type(uint256).max, MathUpgradeable.Rounding.Up), 256);
    }

    function testLog10RoundsDown() public {
        assertEq(_math.log10(0, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log10(1, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log10(2, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log10(9, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log10(10, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log10(11, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log10(99, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log10(100, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log10(101, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log10(999, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log10(1000, MathUpgradeable.Rounding.Down), 3);
        assertEq(_math.log10(1001, MathUpgradeable.Rounding.Down), 3);
        assertEq(_math.log10(type(uint256).max, MathUpgradeable.Rounding.Down), 77);
    }

    function testLog10RoundsUp() public {
        assertEq(_math.log10(0, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.log10(1, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.log10(2, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log10(9, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log10(10, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log10(11, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log10(99, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log10(100, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log10(101, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log10(999, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log10(1000, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log10(1001, MathUpgradeable.Rounding.Up), 4);
        assertEq(_math.log10(type(uint256).max, MathUpgradeable.Rounding.Up), 78);
    }

    function testLog256RoundsDown() public {
        assertEq(_math.log256(0, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log256(1, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log256(2, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log256(255, MathUpgradeable.Rounding.Down), 0);
        assertEq(_math.log256(256, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log256(257, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log256(65535, MathUpgradeable.Rounding.Down), 1);
        assertEq(_math.log256(65536, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log256(65537, MathUpgradeable.Rounding.Down), 2);
        assertEq(_math.log256(type(uint256).max, MathUpgradeable.Rounding.Down), 31);
    }

    function testLog256RoundsUp() public {
        assertEq(_math.log256(0, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.log256(1, MathUpgradeable.Rounding.Up), 0);
        assertEq(_math.log256(2, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log256(255, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log256(256, MathUpgradeable.Rounding.Up), 1);
        assertEq(_math.log256(257, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log256(65535, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log256(65536, MathUpgradeable.Rounding.Up), 2);
        assertEq(_math.log256(65537, MathUpgradeable.Rounding.Up), 3);
        assertEq(_math.log256(type(uint256).max, MathUpgradeable.Rounding.Up), 32);
    }
}
