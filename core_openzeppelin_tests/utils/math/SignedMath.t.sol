// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.0;

import "spark-std/Test.sol";
import "../../../src/utils/math/SignedMath.sol";

contract SignedMathHarness {
    function max(int256 a, int256 b) external pure returns (int256) {
        return SignedMath.max(a, b);
    }

    function min(int256 a, int256 b) external pure returns (int256) {
        return SignedMath.min(a, b);
    }

    function average(int256 a, int256 b) external pure returns (int256) {
        return SignedMath.average(a, b);
    }

    function abs(int256 n) external pure returns (uint256) {
        return SignedMath.abs(n);
    }
}

contract SignedMathTest is Test {
    SignedMathHarness private _math;

    function setUp() public {
        _math = new SignedMathHarness();
    }

    function testMax() public {
        assertEq(int(_math.max(5678, -1234)), int(5678));
        assertEq(int(_math.max(-1234, 5678)), int(5678));
    }

    function testMin() public {
        assertEq(int(_math.min(-1234, 5678)), int(-1234));
        assertEq(int(_math.min(5678, -1234)), int(-1234));
    }

    function testAverage() public {
        int256[] memory valuesX = new int256[](11);
        valuesX[0] = 0;
        valuesX[1] = 3;
        valuesX[2] = -3;
        valuesX[3] = 4;
        valuesX[4] = -4;
        valuesX[5] = 57417;
        valuesX[6] = -57417;
        valuesX[7] = 42304;
        valuesX[8] = -42304;
        valuesX[9] = type(int256).min;
        valuesX[10] = type(int256).max;

        int256[] memory valuesY = new int256[](11);
        valuesY[0] = 0;
        valuesY[1] = 5;
        valuesY[2] = -5;
        valuesY[3] = 2;
        valuesY[4] = -2;
        valuesY[5] = 57417;
        valuesY[6] = -57417;
        valuesY[7] = 42304;
        valuesY[8] = -42304;
        valuesY[9] = type(int256).min;
        valuesY[10] = type(int256).max;

        for (uint256 i = 0; i < valuesX.length; ++i) {
            for (uint256 j = 0; j < valuesY.length; ++j) {
                int256 x = valuesX[i];
                int256 y = valuesY[j];
                int256 expected = _averageExpected(x, y);
                assertEq(int(_math.average(x, y)), int(expected));
            }
        }
    }

    function testAbs() public {
        int256 min = type(int256).min;
        int256 max = type(int256).max;

        assertEq(uint(_math.abs(min)), uint(_absExpected(min)));
        assertEq(uint(_math.abs(min + 1)), uint(_absExpected(min + 1)));
        assertEq(uint(_math.abs(-1)), uint(_absExpected(-1)));
        assertEq(uint(_math.abs(0)), uint(_absExpected(0)));
        assertEq(uint(_math.abs(1)), uint(_absExpected(1)));
        assertEq(uint(_math.abs(max - 1)), uint(_absExpected(max - 1)));
        assertEq(uint(_math.abs(max)), uint(_absExpected(max)));
    }

    function _averageExpected(int256 a, int256 b) private pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    function _absExpected(int256 n) private pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}
