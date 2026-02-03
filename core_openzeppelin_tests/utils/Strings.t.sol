// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.0;

import "spark-std/Test.sol";
import "../../src/utils/Strings.sol";

contract StringsHarness {
    function toStringUint(uint256 value) external pure returns (string memory) {
        return Strings.toString(value);
    }

    function toStringInt(int256 value) external pure returns (string memory) {
        return Strings.toString(value);
    }

    function toHexStringUint(uint256 value) external pure returns (string memory) {
        return Strings.toHexString(value);
    }

    function toHexStringUintFixed(uint256 value, uint256 length) external pure returns (string memory) {
        return Strings.toHexString(value, length);
    }

    function toHexStringAddress(address addr) external pure returns (string memory) {
        return Strings.toHexString(addr);
    }

    function equal(string memory a, string memory b) external pure returns (bool) {
        return Strings.equal(a, b);
    }
}

contract StringsTest is Test {
    StringsHarness private _strings;

    function setUp() public {
        _strings = new StringsHarness();
    }

    function testToStringUintMax() public {
        uint256 value = type(uint256).max;
        assertEq(_strings.toStringUint(value), vm.toString(value));
    }

    function testToStringUintValues() public {
        _assertUintToString(0, "0");
        _assertUintToString(7, "7");
        _assertUintToString(10, "10");
        _assertUintToString(99, "99");
        _assertUintToString(100, "100");
        _assertUintToString(101, "101");
        _assertUintToString(123, "123");
        _assertUintToString(4132, "4132");
        _assertUintToString(12345, "12345");
        _assertUintToString(1234567, "1234567");
        _assertUintToString(1234567890, "1234567890");
        _assertUintToString(123456789012345, "123456789012345");
        _assertUintToString(12345678901234567890, "12345678901234567890");
        _assertUintToString(123456789012345678901234567890, "123456789012345678901234567890");
        _assertUintToString(1234567890123456789012345678901234567890, "1234567890123456789012345678901234567890");
        _assertUintToString(
            12345678901234567890123456789012345678901234567890,
            "12345678901234567890123456789012345678901234567890"
        );
        _assertUintToString(
            123456789012345678901234567890123456789012345678901234567890,
            "123456789012345678901234567890123456789012345678901234567890"
        );
        _assertUintToString(
            1234567890123456789012345678901234567890123456789012345678901234567890,
            "1234567890123456789012345678901234567890123456789012345678901234567890"
        );
    }

    function testToStringIntMaxMin() public {
        int256 maxValue = type(int256).max;
        int256 minValue = type(int256).min;
        assertEq(_strings.toStringInt(maxValue), vm.toString(maxValue));
        assertEq(_strings.toStringInt(minValue), vm.toString(minValue));
    }

    function testToStringIntValues() public {
        _assertIntToString(0, "0");
        _assertIntToString(7, "7");
        _assertIntToString(10, "10");
        _assertIntToString(99, "99");
        _assertIntToString(100, "100");
        _assertIntToString(101, "101");
        _assertIntToString(123, "123");
        _assertIntToString(4132, "4132");
        _assertIntToString(12345, "12345");
        _assertIntToString(1234567, "1234567");
        _assertIntToString(1234567890, "1234567890");
        _assertIntToString(123456789012345, "123456789012345");
        _assertIntToString(12345678901234567890, "12345678901234567890");
        _assertIntToString(123456789012345678901234567890, "123456789012345678901234567890");
        _assertIntToString(1234567890123456789012345678901234567890, "1234567890123456789012345678901234567890");
        _assertIntToString(
            12345678901234567890123456789012345678901234567890,
            "12345678901234567890123456789012345678901234567890"
        );
        _assertIntToString(
            123456789012345678901234567890123456789012345678901234567890,
            "123456789012345678901234567890123456789012345678901234567890"
        );
        _assertIntToString(
            1234567890123456789012345678901234567890123456789012345678901234567890,
            "1234567890123456789012345678901234567890123456789012345678901234567890"
        );

        _assertIntToString(-7, "-7");
        _assertIntToString(-10, "-10");
        _assertIntToString(-99, "-99");
        _assertIntToString(-100, "-100");
        _assertIntToString(-101, "-101");
        _assertIntToString(-123, "-123");
        _assertIntToString(-4132, "-4132");
        _assertIntToString(-12345, "-12345");
        _assertIntToString(-1234567, "-1234567");
        _assertIntToString(-1234567890, "-1234567890");
    }

    function testToHexStringUint() public {
        assertEq(_strings.toHexStringUint(0), "0x00");
        assertEq(_strings.toHexStringUint(0x4132), "0x4132");
        assertEq(
            _strings.toHexStringUint(type(uint256).max),
            "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        );
    }

    function testToHexStringUintFixed() public {
        assertEq(
            _strings.toHexStringUintFixed(0x4132, 32),
            "0x0000000000000000000000000000000000000000000000000000000000004132"
        );

        vm.expectRevert(bytes("Strings: hex length insufficient"));
        _strings.toHexStringUintFixed(0x4132, 1);

        assertEq(
            _strings.toHexStringUintFixed(type(uint256).max, 32),
            "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        );
    }

    function testToHexStringAddressWithLeadingZeros() public {
        address addr = address(uint176(0x0063e0ca771e21bd00057f54a68c30d4000000000000));
        assertEq(_strings.toHexStringAddress(addr), "0x0063e0ca771e21bd00057f54a68c30d4000000000000");
    }

    function testEqual() public {
        assertEq(_strings.equal("", ""), true);
        assertEq(_strings.equal("a", "a"), true);
        assertEq(_strings.equal("a", "b"), false);
        assertEq(_strings.equal("a", "aa"), false);
        assertEq(_strings.equal("aa", "a"), false);
    }

    function testEqualLargeStrings() public {
        string memory str1 = _repeatBytes1(bytes1("a"), 201);
        string memory str2 = _repeatBytes1(bytes1("a"), 200);
        string memory str2b = string(abi.encodePacked(str2, "b"));
        assertEq(_strings.equal(str1, str2b), false);
        assertEq(_strings.equal(str1, str1), true);
    }

    function _assertUintToString(uint256 value, string memory expected) private {
        assertEq(_strings.toStringUint(value), expected);
    }

    function _assertIntToString(int256 value, string memory expected) private {
        assertEq(_strings.toStringInt(value), expected);
    }

    function _repeatBytes1(bytes1 b, uint256 count) private pure returns (string memory) {
        bytes memory out = new bytes(count);
        for (uint256 i = 0; i < count; ++i) {
            out[i] = b;
        }
        return string(out);
    }
}
