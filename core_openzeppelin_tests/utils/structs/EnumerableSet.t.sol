// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/structs/EnumerableSet.sol";

contract EnumerableSetMock {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(uint256 => EnumerableSet.Bytes32Set) private _bytes32Sets;
    mapping(uint256 => EnumerableSet.AddressSet) private _addressSets;
    mapping(uint256 => EnumerableSet.UintSet) private _uintSets;

    // Bytes32Set
    function addBytes32(uint256 setId, bytes32 value) external returns (bool) {
        return _bytes32Sets[setId].add(value);
    }

    function removeBytes32(uint256 setId, bytes32 value) external returns (bool) {
        return _bytes32Sets[setId].remove(value);
    }

    function containsBytes32(uint256 setId, bytes32 value) external view returns (bool) {
        return _bytes32Sets[setId].contains(value);
    }

    function lengthBytes32(uint256 setId) external view returns (uint256) {
        return _bytes32Sets[setId].length();
    }

    function atBytes32(uint256 setId, uint256 index) external view returns (bytes32) {
        return _bytes32Sets[setId].at(index);
    }

    function valuesBytes32(uint256 setId) external view returns (bytes32[] memory) {
        return _bytes32Sets[setId].values();
    }

    // AddressSet
    function addAddress(uint256 setId, address value) external returns (bool) {
        return _addressSets[setId].add(value);
    }

    function removeAddress(uint256 setId, address value) external returns (bool) {
        return _addressSets[setId].remove(value);
    }

    function containsAddress(uint256 setId, address value) external view returns (bool) {
        return _addressSets[setId].contains(value);
    }

    function lengthAddress(uint256 setId) external view returns (uint256) {
        return _addressSets[setId].length();
    }

    function atAddress(uint256 setId, uint256 index) external view returns (address) {
        return _addressSets[setId].at(index);
    }

    function valuesAddress(uint256 setId) external view returns (address[] memory) {
        return _addressSets[setId].values();
    }

    // UintSet
    function addUint(uint256 setId, uint256 value) external returns (bool) {
        return _uintSets[setId].add(value);
    }

    function removeUint(uint256 setId, uint256 value) external returns (bool) {
        return _uintSets[setId].remove(value);
    }

    function containsUint(uint256 setId, uint256 value) external view returns (bool) {
        return _uintSets[setId].contains(value);
    }

    function lengthUint(uint256 setId) external view returns (uint256) {
        return _uintSets[setId].length();
    }

    function atUint(uint256 setId, uint256 index) external view returns (uint256) {
        return _uintSets[setId].at(index);
    }

    function valuesUint(uint256 setId) external view returns (uint256[] memory) {
        return _uintSets[setId].values();
    }
}

contract EnumerableSetTest is Test {
    EnumerableSetMock private _set;

    bytes32 private constant _B32_A = bytes32(uint256(0xdeadbeef));
    bytes32 private constant _B32_B = bytes32(uint256(0x0123456789));
    bytes32 private constant _B32_C = bytes32(uint256(0x42424242));

    address private constant _ADDR_A = address(0xA11CE);
    address private constant _ADDR_B = address(0xB0B);
    address private constant _ADDR_C = address(0xCAFE);

    uint256 private constant _UINT_A = 1234;
    uint256 private constant _UINT_B = 5678;
    uint256 private constant _UINT_C = 9101112;

    function setUp() public {
        _set = new EnumerableSetMock();
    }

    // Bytes32Set
    function testBytes32StartsEmpty() public {
        assertEq(_set.containsBytes32(0, _B32_A), false);
        _assertBytes32Members(new bytes32[](0));
    }

    function testBytes32AddSingle() public {
        assertEq(_set.addBytes32(0, _B32_A), true);
        _assertBytes32Members(_toBytes32Array(_B32_A));
    }

    function testBytes32AddSeveral() public {
        _set.addBytes32(0, _B32_A);
        _set.addBytes32(0, _B32_B);
        _assertBytes32Members(_toBytes32Array(_B32_A, _B32_B));
        assertEq(_set.containsBytes32(0, _B32_C), false);
    }

    function testBytes32AddExistingReturnsFalse() public {
        _set.addBytes32(0, _B32_A);
        assertEq(_set.addBytes32(0, _B32_A), false);
        _assertBytes32Members(_toBytes32Array(_B32_A));
    }

    function testBytes32AtRevertsOnEmpty() public {
        vm.expectRevert();
        _set.atBytes32(0, 0);
    }

    function testBytes32RemoveAdded() public {
        _set.addBytes32(0, _B32_A);
        assertEq(_set.removeBytes32(0, _B32_A), true);
        assertEq(_set.containsBytes32(0, _B32_A), false);
        _assertBytes32Members(new bytes32[](0));
    }

    function testBytes32RemoveNotPresent() public {
        assertEq(_set.removeBytes32(0, _B32_A), false);
        assertEq(_set.containsBytes32(0, _B32_A), false);
    }

    function testBytes32AddRemoveMultiple() public {
        _set.addBytes32(0, _B32_A);
        _set.addBytes32(0, _B32_C);

        _set.removeBytes32(0, _B32_A);
        _set.removeBytes32(0, _B32_B);

        _set.addBytes32(0, _B32_B);
        _set.addBytes32(0, _B32_A);
        _set.removeBytes32(0, _B32_C);

        _set.addBytes32(0, _B32_A);
        _set.addBytes32(0, _B32_B);

        _set.addBytes32(0, _B32_C);
        _set.removeBytes32(0, _B32_A);

        _set.addBytes32(0, _B32_A);
        _set.removeBytes32(0, _B32_B);

        _assertBytes32Members(_toBytes32Array(_B32_A, _B32_C));
        assertEq(_set.containsBytes32(0, _B32_B), false);
    }

    // AddressSet
    function testAddressStartsEmpty() public {
        assertEq(_set.containsAddress(0, _ADDR_A), false);
        _assertAddressMembers(new address[](0));
    }

    function testAddressAddSingle() public {
        assertEq(_set.addAddress(0, _ADDR_A), true);
        _assertAddressMembers(_toAddressArray(_ADDR_A));
    }

    function testAddressAddSeveral() public {
        _set.addAddress(0, _ADDR_A);
        _set.addAddress(0, _ADDR_B);
        _assertAddressMembers(_toAddressArray(_ADDR_A, _ADDR_B));
        assertEq(_set.containsAddress(0, _ADDR_C), false);
    }

    function testAddressAddExistingReturnsFalse() public {
        _set.addAddress(0, _ADDR_A);
        assertEq(_set.addAddress(0, _ADDR_A), false);
        _assertAddressMembers(_toAddressArray(_ADDR_A));
    }

    function testAddressAtRevertsOnEmpty() public {
        vm.expectRevert();
        _set.atAddress(0, 0);
    }

    function testAddressRemoveAdded() public {
        _set.addAddress(0, _ADDR_A);
        assertEq(_set.removeAddress(0, _ADDR_A), true);
        assertEq(_set.containsAddress(0, _ADDR_A), false);
        _assertAddressMembers(new address[](0));
    }

    function testAddressRemoveNotPresent() public {
        assertEq(_set.removeAddress(0, _ADDR_A), false);
        assertEq(_set.containsAddress(0, _ADDR_A), false);
    }

    function testAddressAddRemoveMultiple() public {
        _set.addAddress(0, _ADDR_A);
        _set.addAddress(0, _ADDR_C);

        _set.removeAddress(0, _ADDR_A);
        _set.removeAddress(0, _ADDR_B);

        _set.addAddress(0, _ADDR_B);
        _set.addAddress(0, _ADDR_A);
        _set.removeAddress(0, _ADDR_C);

        _set.addAddress(0, _ADDR_A);
        _set.addAddress(0, _ADDR_B);

        _set.addAddress(0, _ADDR_C);
        _set.removeAddress(0, _ADDR_A);

        _set.addAddress(0, _ADDR_A);
        _set.removeAddress(0, _ADDR_B);

        _assertAddressMembers(_toAddressArray(_ADDR_A, _ADDR_C));
        assertEq(_set.containsAddress(0, _ADDR_B), false);
    }

    // UintSet
    function testUintStartsEmpty() public {
        assertEq(_set.containsUint(0, _UINT_A), false);
        _assertUintMembers(new uint256[](0));
    }

    function testUintAddSingle() public {
        assertEq(_set.addUint(0, _UINT_A), true);
        _assertUintMembers(_toUintArray(_UINT_A));
    }

    function testUintAddSeveral() public {
        _set.addUint(0, _UINT_A);
        _set.addUint(0, _UINT_B);
        _assertUintMembers(_toUintArray(_UINT_A, _UINT_B));
        assertEq(_set.containsUint(0, _UINT_C), false);
    }

    function testUintAddExistingReturnsFalse() public {
        _set.addUint(0, _UINT_A);
        assertEq(_set.addUint(0, _UINT_A), false);
        _assertUintMembers(_toUintArray(_UINT_A));
    }

    function testUintAtRevertsOnEmpty() public {
        vm.expectRevert();
        _set.atUint(0, 0);
    }

    function testUintRemoveAdded() public {
        _set.addUint(0, _UINT_A);
        assertEq(_set.removeUint(0, _UINT_A), true);
        assertEq(_set.containsUint(0, _UINT_A), false);
        _assertUintMembers(new uint256[](0));
    }

    function testUintRemoveNotPresent() public {
        assertEq(_set.removeUint(0, _UINT_A), false);
        assertEq(_set.containsUint(0, _UINT_A), false);
    }

    function testUintAddRemoveMultiple() public {
        _set.addUint(0, _UINT_A);
        _set.addUint(0, _UINT_C);

        _set.removeUint(0, _UINT_A);
        _set.removeUint(0, _UINT_B);

        _set.addUint(0, _UINT_B);
        _set.addUint(0, _UINT_A);
        _set.removeUint(0, _UINT_C);

        _set.addUint(0, _UINT_A);
        _set.addUint(0, _UINT_B);

        _set.addUint(0, _UINT_C);
        _set.removeUint(0, _UINT_A);

        _set.addUint(0, _UINT_A);
        _set.removeUint(0, _UINT_B);

        _assertUintMembers(_toUintArray(_UINT_A, _UINT_C));
        assertEq(_set.containsUint(0, _UINT_B), false);
    }

    function _assertBytes32Members(bytes32[] memory expected) private {
        for (uint256 i = 0; i < expected.length; ++i) {
            assertEq(_set.containsBytes32(0, expected[i]), true);
        }

        assertEq(_set.lengthBytes32(0), expected.length);

        bytes32[] memory indexedValues = new bytes32[](expected.length);
        for (uint256 i = 0; i < expected.length; ++i) {
            indexedValues[i] = _set.atBytes32(0, i);
        }
        _assertSameBytes32Members(indexedValues, expected);

        bytes32[] memory returned = _set.valuesBytes32(0);
        _assertSameBytes32Members(returned, expected);
    }

    function _assertAddressMembers(address[] memory expected) private {
        for (uint256 i = 0; i < expected.length; ++i) {
            assertEq(_set.containsAddress(0, expected[i]), true);
        }

        assertEq(_set.lengthAddress(0), expected.length);

        address[] memory indexedValues = new address[](expected.length);
        for (uint256 i = 0; i < expected.length; ++i) {
            indexedValues[i] = _set.atAddress(0, i);
        }
        _assertSameAddressMembers(indexedValues, expected);

        address[] memory returned = _set.valuesAddress(0);
        _assertSameAddressMembers(returned, expected);
    }

    function _assertUintMembers(uint256[] memory expected) private {
        for (uint256 i = 0; i < expected.length; ++i) {
            assertEq(_set.containsUint(0, expected[i]), true);
        }

        assertEq(_set.lengthUint(0), expected.length);

        uint256[] memory indexedValues = new uint256[](expected.length);
        for (uint256 i = 0; i < expected.length; ++i) {
            indexedValues[i] = _set.atUint(0, i);
        }
        _assertSameUintMembers(indexedValues, expected);

        uint256[] memory returned = _set.valuesUint(0);
        _assertSameUintMembers(returned, expected);
    }

    function _assertSameBytes32Members(bytes32[] memory actual, bytes32[] memory expected) private {
        assertEq(actual.length, expected.length);
        for (uint256 i = 0; i < expected.length; ++i) {
            bool found = false;
            for (uint256 j = 0; j < actual.length; ++j) {
                if (actual[j] == expected[i]) {
                    found = true;
                    break;
                }
            }
            assertEq(found, true);
        }
    }

    function _assertSameAddressMembers(address[] memory actual, address[] memory expected) private {
        assertEq(actual.length, expected.length);
        for (uint256 i = 0; i < expected.length; ++i) {
            bool found = false;
            for (uint256 j = 0; j < actual.length; ++j) {
                if (actual[j] == expected[i]) {
                    found = true;
                    break;
                }
            }
            assertEq(found, true);
        }
    }

    function _assertSameUintMembers(uint256[] memory actual, uint256[] memory expected) private {
        assertEq(actual.length, expected.length);
        for (uint256 i = 0; i < expected.length; ++i) {
            bool found = false;
            for (uint256 j = 0; j < actual.length; ++j) {
                if (actual[j] == expected[i]) {
                    found = true;
                    break;
                }
            }
            assertEq(found, true);
        }
    }

    function _toBytes32Array(bytes32 a) private pure returns (bytes32[] memory arr) {
        arr = new bytes32[](1);
        arr[0] = a;
    }

    function _toBytes32Array(bytes32 a, bytes32 b) private pure returns (bytes32[] memory arr) {
        arr = new bytes32[](2);
        arr[0] = a;
        arr[1] = b;
    }

    function _toAddressArray(address a) private pure returns (address[] memory arr) {
        arr = new address[](1);
        arr[0] = a;
    }

    function _toAddressArray(address a, address b) private pure returns (address[] memory arr) {
        arr = new address[](2);
        arr[0] = a;
        arr[1] = b;
    }

    function _toUintArray(uint256 a) private pure returns (uint256[] memory arr) {
        arr = new uint256[](1);
        arr[0] = a;
    }

    function _toUintArray(uint256 a, uint256 b) private pure returns (uint256[] memory arr) {
        arr = new uint256[](2);
        arr[0] = a;
        arr[1] = b;
    }
}
