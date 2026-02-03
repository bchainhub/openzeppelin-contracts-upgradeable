// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/Arrays.sol";

contract Uint256ArraysMock {
    using Arrays for uint256[];

    uint256[] private _array;

    constructor(uint256[] memory array) {
        _array = array;
    }

    function findUpperBound(uint256 element) external view returns (uint256) {
        return _array.findUpperBound(element);
    }

    function unsafeAccess(uint256 pos) external view returns (uint256) {
        return _array.unsafeAccess(pos).value;
    }
}

contract AddressArraysMock {
    using Arrays for address[];

    address[] private _array;

    constructor(address[] memory array) {
        _array = array;
    }

    function unsafeAccess(uint256 pos) external view returns (address) {
        return _array.unsafeAccess(pos).value;
    }
}

contract Bytes32ArraysMock {
    using Arrays for bytes32[];

    bytes32[] private _array;

    constructor(bytes32[] memory array) {
        _array = array;
    }

    function unsafeAccess(uint256 pos) external view returns (bytes32) {
        return _array.unsafeAccess(pos).value;
    }
}

contract ArraysTest is Test {
    function testFindUpperBoundEvenBasicCase() public {
        uint256[] memory array = _evenElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(16), 5);
    }

    function testFindUpperBoundEvenFirstElement() public {
        uint256[] memory array = _evenElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(11), 0);
    }

    function testFindUpperBoundEvenLastElement() public {
        uint256[] memory array = _evenElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(20), 9);
    }

    function testFindUpperBoundEvenOverUpperBoundary() public {
        uint256[] memory array = _evenElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(32), 10);
    }

    function testFindUpperBoundEvenUnderLowerBoundary() public {
        uint256[] memory array = _evenElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(2), 0);
    }

    function testFindUpperBoundOddBasicCase() public {
        uint256[] memory array = _oddElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(16), 5);
    }

    function testFindUpperBoundOddFirstElement() public {
        uint256[] memory array = _oddElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(11), 0);
    }

    function testFindUpperBoundOddLastElement() public {
        uint256[] memory array = _oddElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(21), 10);
    }

    function testFindUpperBoundOddOverUpperBoundary() public {
        uint256[] memory array = _oddElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(32), 11);
    }

    function testFindUpperBoundOddUnderLowerBoundary() public {
        uint256[] memory array = _oddElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(2), 0);
    }

    function testFindUpperBoundArrayWithGap() public {
        uint256[] memory array = _gapElementsArray();
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(17), 5);
    }

    function testFindUpperBoundEmptyArray() public {
        uint256[] memory array = new uint256[](0);
        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        assertEq(mock.findUpperBound(10), 0);
    }

    function testUnsafeAccessAddressArray() public {
        address[] memory array = new address[](10);
        for (uint256 i = 0; i < array.length; ++i) {
            array[i] = address(uint176(uint256(keccak256(abi.encodePacked("addr", i)))));
        }

        AddressArraysMock mock = new AddressArraysMock(array);
        for (uint256 i = 0; i < array.length; ++i) {
            assertEq(mock.unsafeAccess(i), array[i]);
        }
    }

    function testUnsafeAccessBytes32Array() public {
        bytes32[] memory array = new bytes32[](10);
        for (uint256 i = 0; i < array.length; ++i) {
            array[i] = keccak256(abi.encodePacked("bytes32", i));
        }

        Bytes32ArraysMock mock = new Bytes32ArraysMock(array);
        for (uint256 i = 0; i < array.length; ++i) {
            assertEq(mock.unsafeAccess(i), array[i]);
        }
    }

    function testUnsafeAccessUint256Array() public {
        uint256[] memory array = new uint256[](10);
        for (uint256 i = 0; i < array.length; ++i) {
            array[i] = uint256(keccak256(abi.encodePacked("uint256", i)));
        }

        Uint256ArraysMock mock = new Uint256ArraysMock(array);
        for (uint256 i = 0; i < array.length; ++i) {
            assertEq(mock.unsafeAccess(i), array[i]);
        }
    }

    function _evenElementsArray() private pure returns (uint256[] memory array) {
        array = new uint256[](10);
        for (uint256 i = 0; i < array.length; ++i) {
            array[i] = 11 + i;
        }
    }

    function _oddElementsArray() private pure returns (uint256[] memory array) {
        array = new uint256[](11);
        for (uint256 i = 0; i < array.length; ++i) {
            array[i] = 11 + i;
        }
    }

    function _gapElementsArray() private pure returns (uint256[] memory array) {
        array = new uint256[](10);
        array[0] = 11;
        array[1] = 12;
        array[2] = 13;
        array[3] = 14;
        array[4] = 15;
        array[5] = 20;
        array[6] = 21;
        array[7] = 22;
        array[8] = 23;
        array[9] = 24;
    }
}
