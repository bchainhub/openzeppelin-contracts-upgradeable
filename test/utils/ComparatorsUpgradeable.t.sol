// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/ComparatorsUpgradeable.sol";

contract ComparatorsUpgradeableHarness {
    function lt(uint256 a, uint256 b) external pure returns (bool) {
        return ComparatorsUpgradeable.lt(a, b);
    }

    function gt(uint256 a, uint256 b) external pure returns (bool) {
        return ComparatorsUpgradeable.gt(a, b);
    }
}

contract ComparatorsUpgradeableTest is Test {
    ComparatorsUpgradeableHarness private _comparators;

    function setUp() public {
        _comparators = new ComparatorsUpgradeableHarness();
    }

    function testLtReturnsTrueOnlyWhenStrictlyLess() public {
        assertTrue(_comparators.lt(1, 2));
        assertFalse(_comparators.lt(2, 2));
        assertFalse(_comparators.lt(3, 2));
    }

    function testGtReturnsTrueOnlyWhenStrictlyGreater() public {
        assertTrue(_comparators.gt(3, 2));
        assertFalse(_comparators.gt(2, 2));
        assertFalse(_comparators.gt(1, 2));
    }

    function testComparatorsHandleUint256Extremes() public {
        assertTrue(_comparators.lt(0, type(uint256).max));
        assertFalse(_comparators.gt(0, type(uint256).max));
        assertTrue(_comparators.gt(type(uint256).max, 0));
        assertFalse(_comparators.lt(type(uint256).max, 0));
    }
}
