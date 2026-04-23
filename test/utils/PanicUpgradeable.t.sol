// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/PanicUpgradeable.sol";

contract PanicUpgradeableHarness {
    uint256[] private _storageArray;

    function triggerAssert() external pure {
        assert(false);
    }

    function triggerOverflow() external pure returns (uint256) {
        uint256 value = type(uint256).max;
        return value + 1;
    }

    function triggerDivisionByZero() external pure returns (uint256) {
        uint256 numerator = 1;
        uint256 denominator = 0;
        return numerator / denominator;
    }

    function triggerEmptyArrayPop() external {
        delete _storageArray;
        _storageArray.pop();
    }

    function triggerArrayOutOfBounds() external pure returns (uint256) {
        uint256[] memory array = new uint256[](0);
        return array[0];
    }
}

contract PanicUpgradeableLibraryHarness {
    function panicWithCode(uint256 code) external pure {
        PanicUpgradeable.panic(code);
    }

    function generic() external pure returns (uint256) {
        return PanicUpgradeable.GENERIC;
    }

    function assertCode() external pure returns (uint256) {
        return PanicUpgradeable.ASSERT;
    }

    function underOverflow() external pure returns (uint256) {
        return PanicUpgradeable.UNDER_OVERFLOW;
    }

    function divisionByZero() external pure returns (uint256) {
        return PanicUpgradeable.DIVISION_BY_ZERO;
    }

    function enumConversionError() external pure returns (uint256) {
        return PanicUpgradeable.ENUM_CONVERSION_ERROR;
    }

    function storageEncodingError() external pure returns (uint256) {
        return PanicUpgradeable.STORAGE_ENCODING_ERROR;
    }

    function emptyArrayPop() external pure returns (uint256) {
        return PanicUpgradeable.EMPTY_ARRAY_POP;
    }

    function arrayOutOfBounds() external pure returns (uint256) {
        return PanicUpgradeable.ARRAY_OUT_OF_BOUNDS;
    }

    function resourceError() external pure returns (uint256) {
        return PanicUpgradeable.RESOURCE_ERROR;
    }

    function invalidInternalFunction() external pure returns (uint256) {
        return PanicUpgradeable.INVALID_INTERNAL_FUNCTION;
    }
}

contract PanicUpgradeableTest is Test {
    bytes4 private constant _SOLIDITY_PANIC_SELECTOR = 0x4e487b71;
    bytes4 private constant _CORE_PANIC_SELECTOR = 0x4b1f2ce3;

    PanicUpgradeableHarness private _panicHarness;
    PanicUpgradeableLibraryHarness private _panicLibraryHarness;

    function setUp() public {
        _panicHarness = new PanicUpgradeableHarness();
        _panicLibraryHarness = new PanicUpgradeableLibraryHarness();
    }

    function testAssertMatchesStandardPanicCode() public {
        _assertPanic(address(_panicHarness), abi.encodeWithSelector(_panicHarness.triggerAssert.selector), 0x01);
    }

    function testOverflowMatchesStandardPanicCode() public {
        _assertPanic(address(_panicHarness), abi.encodeWithSelector(_panicHarness.triggerOverflow.selector), 0x11);
    }

    function testDivisionByZeroMatchesStandardPanicCode() public {
        _assertPanic(address(_panicHarness), abi.encodeWithSelector(_panicHarness.triggerDivisionByZero.selector), 0x12);
    }

    function testEmptyArrayPopMatchesStandardPanicCode() public {
        _assertPanic(address(_panicHarness), abi.encodeWithSelector(_panicHarness.triggerEmptyArrayPop.selector), 0x31);
    }

    function testArrayOutOfBoundsMatchesStandardPanicCode() public {
        _assertPanic(address(_panicHarness), abi.encodeWithSelector(_panicHarness.triggerArrayOutOfBounds.selector), 0x32);
    }

    function testPortedPanicConstantsMatchExpectedCodes() public {
        assertEq(_panicLibraryHarness.generic(), 0x00);
        assertEq(_panicLibraryHarness.assertCode(), 0x01);
        assertEq(_panicLibraryHarness.underOverflow(), 0x11);
        assertEq(_panicLibraryHarness.divisionByZero(), 0x12);
        assertEq(_panicLibraryHarness.enumConversionError(), 0x21);
        assertEq(_panicLibraryHarness.storageEncodingError(), 0x22);
        assertEq(_panicLibraryHarness.emptyArrayPop(), 0x31);
        assertEq(_panicLibraryHarness.arrayOutOfBounds(), 0x32);
        assertEq(_panicLibraryHarness.resourceError(), 0x41);
        assertEq(_panicLibraryHarness.invalidInternalFunction(), 0x51);
    }

    function testPortedPanicLibraryUsesCorePanicSelector() public {
        _assertPanic(
            address(_panicLibraryHarness), abi.encodeWithSelector(_panicLibraryHarness.panicWithCode.selector, 0x31), 0x31
        );
        _assertPanic(
            address(_panicLibraryHarness), abi.encodeWithSelector(_panicLibraryHarness.panicWithCode.selector, 0x12), 0x12
        );
    }

    function _assertPanic(address target, bytes memory data, uint256 code) private {
        (bool ok, bytes memory returndata) = target.call(data);
        assertFalse(ok);
        assertEq(returndata, abi.encodeWithSelector(_CORE_PANIC_SELECTOR, code));
        assertTrue(keccak256(returndata) != keccak256(abi.encodeWithSelector(_SOLIDITY_PANIC_SELECTOR, code)));
    }
}
