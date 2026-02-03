// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/structs/EnumerableMap.sol";

contract EnumerableMapMock {
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using EnumerableMap for EnumerableMap.Bytes32ToUintMap;

    mapping(uint256 => EnumerableMap.AddressToUintMap) private _addressToUint;
    mapping(uint256 => EnumerableMap.UintToAddressMap) private _uintToAddress;
    mapping(uint256 => EnumerableMap.Bytes32ToBytes32Map) private _bytes32ToBytes32;
    mapping(uint256 => EnumerableMap.UintToUintMap) private _uintToUint;
    mapping(uint256 => EnumerableMap.Bytes32ToUintMap) private _bytes32ToUint;

    // AddressToUintMap
    function setAddressToUint(uint256 mapId, address key, uint256 value) external returns (bool) {
        return _addressToUint[mapId].set(key, value);
    }

    function getAddressToUint(uint256 mapId, address key) external view returns (uint256) {
        return _addressToUint[mapId].get(key);
    }

    function getAddressToUint(uint256 mapId, address key, string memory errorMessage) external view returns (uint256) {
        return _addressToUint[mapId].get(key, errorMessage);
    }

    function tryGetAddressToUint(uint256 mapId, address key) external view returns (bool, uint256) {
        return _addressToUint[mapId].tryGet(key);
    }

    function removeAddressToUint(uint256 mapId, address key) external returns (bool) {
        return _addressToUint[mapId].remove(key);
    }

    function lengthAddressToUint(uint256 mapId) external view returns (uint256) {
        return _addressToUint[mapId].length();
    }

    function atAddressToUint(uint256 mapId, uint256 index) external view returns (address, uint256) {
        return _addressToUint[mapId].at(index);
    }

    function containsAddressToUint(uint256 mapId, address key) external view returns (bool) {
        return _addressToUint[mapId].contains(key);
    }

    function keysAddressToUint(uint256 mapId) external view returns (address[] memory) {
        return _addressToUint[mapId].keys();
    }

    // UintToAddressMap
    function setUintToAddress(uint256 mapId, uint256 key, address value) external returns (bool) {
        return _uintToAddress[mapId].set(key, value);
    }

    function getUintToAddress(uint256 mapId, uint256 key) external view returns (address) {
        return _uintToAddress[mapId].get(key);
    }

    function getUintToAddress(uint256 mapId, uint256 key, string memory errorMessage) external view returns (address) {
        return _uintToAddress[mapId].get(key, errorMessage);
    }

    function tryGetUintToAddress(uint256 mapId, uint256 key) external view returns (bool, address) {
        return _uintToAddress[mapId].tryGet(key);
    }

    function removeUintToAddress(uint256 mapId, uint256 key) external returns (bool) {
        return _uintToAddress[mapId].remove(key);
    }

    function lengthUintToAddress(uint256 mapId) external view returns (uint256) {
        return _uintToAddress[mapId].length();
    }

    function atUintToAddress(uint256 mapId, uint256 index) external view returns (uint256, address) {
        return _uintToAddress[mapId].at(index);
    }

    function containsUintToAddress(uint256 mapId, uint256 key) external view returns (bool) {
        return _uintToAddress[mapId].contains(key);
    }

    function keysUintToAddress(uint256 mapId) external view returns (uint256[] memory) {
        return _uintToAddress[mapId].keys();
    }

    // Bytes32ToBytes32Map
    function setBytes32ToBytes32(uint256 mapId, bytes32 key, bytes32 value) external returns (bool) {
        return _bytes32ToBytes32[mapId].set(key, value);
    }

    function getBytes32ToBytes32(uint256 mapId, bytes32 key) external view returns (bytes32) {
        return _bytes32ToBytes32[mapId].get(key);
    }

    function getBytes32ToBytes32(uint256 mapId, bytes32 key, string memory errorMessage) external view returns (bytes32) {
        return _bytes32ToBytes32[mapId].get(key, errorMessage);
    }

    function tryGetBytes32ToBytes32(uint256 mapId, bytes32 key) external view returns (bool, bytes32) {
        return _bytes32ToBytes32[mapId].tryGet(key);
    }

    function removeBytes32ToBytes32(uint256 mapId, bytes32 key) external returns (bool) {
        return _bytes32ToBytes32[mapId].remove(key);
    }

    function lengthBytes32ToBytes32(uint256 mapId) external view returns (uint256) {
        return _bytes32ToBytes32[mapId].length();
    }

    function atBytes32ToBytes32(uint256 mapId, uint256 index) external view returns (bytes32, bytes32) {
        return _bytes32ToBytes32[mapId].at(index);
    }

    function containsBytes32ToBytes32(uint256 mapId, bytes32 key) external view returns (bool) {
        return _bytes32ToBytes32[mapId].contains(key);
    }

    function keysBytes32ToBytes32(uint256 mapId) external view returns (bytes32[] memory) {
        return _bytes32ToBytes32[mapId].keys();
    }

    // UintToUintMap
    function setUintToUint(uint256 mapId, uint256 key, uint256 value) external returns (bool) {
        return _uintToUint[mapId].set(key, value);
    }

    function getUintToUint(uint256 mapId, uint256 key) external view returns (uint256) {
        return _uintToUint[mapId].get(key);
    }

    function getUintToUint(uint256 mapId, uint256 key, string memory errorMessage) external view returns (uint256) {
        return _uintToUint[mapId].get(key, errorMessage);
    }

    function tryGetUintToUint(uint256 mapId, uint256 key) external view returns (bool, uint256) {
        return _uintToUint[mapId].tryGet(key);
    }

    function removeUintToUint(uint256 mapId, uint256 key) external returns (bool) {
        return _uintToUint[mapId].remove(key);
    }

    function lengthUintToUint(uint256 mapId) external view returns (uint256) {
        return _uintToUint[mapId].length();
    }

    function atUintToUint(uint256 mapId, uint256 index) external view returns (uint256, uint256) {
        return _uintToUint[mapId].at(index);
    }

    function containsUintToUint(uint256 mapId, uint256 key) external view returns (bool) {
        return _uintToUint[mapId].contains(key);
    }

    function keysUintToUint(uint256 mapId) external view returns (uint256[] memory) {
        return _uintToUint[mapId].keys();
    }

    // Bytes32ToUintMap
    function setBytes32ToUint(uint256 mapId, bytes32 key, uint256 value) external returns (bool) {
        return _bytes32ToUint[mapId].set(key, value);
    }

    function getBytes32ToUint(uint256 mapId, bytes32 key) external view returns (uint256) {
        return _bytes32ToUint[mapId].get(key);
    }

    function getBytes32ToUint(uint256 mapId, bytes32 key, string memory errorMessage) external view returns (uint256) {
        return _bytes32ToUint[mapId].get(key, errorMessage);
    }

    function tryGetBytes32ToUint(uint256 mapId, bytes32 key) external view returns (bool, uint256) {
        return _bytes32ToUint[mapId].tryGet(key);
    }

    function removeBytes32ToUint(uint256 mapId, bytes32 key) external returns (bool) {
        return _bytes32ToUint[mapId].remove(key);
    }

    function lengthBytes32ToUint(uint256 mapId) external view returns (uint256) {
        return _bytes32ToUint[mapId].length();
    }

    function atBytes32ToUint(uint256 mapId, uint256 index) external view returns (bytes32, uint256) {
        return _bytes32ToUint[mapId].at(index);
    }

    function containsBytes32ToUint(uint256 mapId, bytes32 key) external view returns (bool) {
        return _bytes32ToUint[mapId].contains(key);
    }

    function keysBytes32ToUint(uint256 mapId) external view returns (bytes32[] memory) {
        return _bytes32ToUint[mapId].keys();
    }
}

contract EnumerableMapTest is Test {
    EnumerableMapMock private _map;

    address private constant _ADDR_A = address(0xA11CE);
    address private constant _ADDR_B = address(0xB0B);
    address private constant _ADDR_C = address(0xCAFE);

    uint256 private constant _KEY_A = 7891;
    uint256 private constant _KEY_B = 451;
    uint256 private constant _KEY_C = 9592328;

    bytes32 private constant _B32_A = bytes32(uint256(0xdeadbeef));
    bytes32 private constant _B32_B = bytes32(uint256(0x0123456789));
    bytes32 private constant _B32_C = bytes32(uint256(0x42424242));

    function setUp() public {
        _map = new EnumerableMapMock();
    }

    // AddressToUintMap
    function testAddressToUintStartsEmpty() public {
        assertEq(_map.containsAddressToUint(0, _ADDR_A), false);
        _assertAddressToUintMembers(new address[](0), new uint256[](0));
    }

    function testAddressToUintSetAdd() public {
        assertEq(_map.setAddressToUint(0, _ADDR_A, _KEY_A), true);
        _assertAddressToUintMembers(_toAddressArray(_ADDR_A), _toUintArray(_KEY_A));
    }

    function testAddressToUintSetUpdate() public {
        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        assertEq(_map.setAddressToUint(0, _ADDR_A, _KEY_B), false);
        _assertAddressToUintMembers(_toAddressArray(_ADDR_A), _toUintArray(_KEY_B));
    }

    function testAddressToUintRemove() public {
        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        assertEq(_map.removeAddressToUint(0, _ADDR_A), true);
        assertEq(_map.containsAddressToUint(0, _ADDR_A), false);
        _assertAddressToUintMembers(new address[](0), new uint256[](0));
    }

    function testAddressToUintTryGetAndGet() public {
        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        (bool ok, uint256 value) = _map.tryGetAddressToUint(0, _ADDR_A);
        assertEq(ok, true);
        assertEq(value, _KEY_A);

        (bool okMissing, uint256 valueMissing) = _map.tryGetAddressToUint(0, _ADDR_B);
        assertEq(okMissing, false);
        assertEq(valueMissing, 0);

        assertEq(_map.getAddressToUint(0, _ADDR_A), _KEY_A);

        vm.expectRevert(bytes("EnumerableMap: nonexistent key"));
        _map.getAddressToUint(0, _ADDR_B);

        vm.expectRevert(bytes("custom error string"));
        _map.getAddressToUint(0, _ADDR_B, "custom error string");
    }

    function testAddressToUintAddRemoveMultiple() public {
        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        _map.setAddressToUint(0, _ADDR_C, _KEY_C);

        _map.removeAddressToUint(0, _ADDR_A);
        _map.removeAddressToUint(0, _ADDR_B);

        _map.setAddressToUint(0, _ADDR_B, _KEY_B);
        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        _map.removeAddressToUint(0, _ADDR_C);

        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        _map.setAddressToUint(0, _ADDR_B, _KEY_B);

        _map.setAddressToUint(0, _ADDR_C, _KEY_C);
        _map.removeAddressToUint(0, _ADDR_A);

        _map.setAddressToUint(0, _ADDR_A, _KEY_A);
        _map.removeAddressToUint(0, _ADDR_B);

        _assertAddressToUintMembers(_toAddressArray(_ADDR_A, _ADDR_C), _toUintArray(_KEY_A, _KEY_C));
        assertEq(_map.containsAddressToUint(0, _ADDR_A), true);
        assertEq(_map.containsAddressToUint(0, _ADDR_B), false);
        assertEq(_map.containsAddressToUint(0, _ADDR_C), true);
    }

    // UintToAddressMap
    function testUintToAddressStartsEmpty() public {
        assertEq(_map.containsUintToAddress(0, _KEY_A), false);
        _assertUintToAddressMembers(new uint256[](0), new address[](0));
    }

    function testUintToAddressSetAdd() public {
        assertEq(_map.setUintToAddress(0, _KEY_A, _ADDR_A), true);
        _assertUintToAddressMembers(_toUintArray(_KEY_A), _toAddressArray(_ADDR_A));
    }

    function testUintToAddressSetUpdate() public {
        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        assertEq(_map.setUintToAddress(0, _KEY_A, _ADDR_B), false);
        _assertUintToAddressMembers(_toUintArray(_KEY_A), _toAddressArray(_ADDR_B));
    }

    function testUintToAddressRemove() public {
        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        assertEq(_map.removeUintToAddress(0, _KEY_A), true);
        assertEq(_map.containsUintToAddress(0, _KEY_A), false);
        _assertUintToAddressMembers(new uint256[](0), new address[](0));
    }

    function testUintToAddressTryGetAndGet() public {
        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        (bool ok, address value) = _map.tryGetUintToAddress(0, _KEY_A);
        assertEq(ok, true);
        assertEq(value, _ADDR_A);

        (bool okMissing, address valueMissing) = _map.tryGetUintToAddress(0, _KEY_B);
        assertEq(okMissing, false);
        assertEq(valueMissing, address(0));

        assertEq(_map.getUintToAddress(0, _KEY_A), _ADDR_A);

        vm.expectRevert(bytes("EnumerableMap: nonexistent key"));
        _map.getUintToAddress(0, _KEY_B);

        vm.expectRevert(bytes("custom error string"));
        _map.getUintToAddress(0, _KEY_B, "custom error string");
    }

    function testUintToAddressAddRemoveMultiple() public {
        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        _map.setUintToAddress(0, _KEY_C, _ADDR_C);

        _map.removeUintToAddress(0, _KEY_A);
        _map.removeUintToAddress(0, _KEY_B);

        _map.setUintToAddress(0, _KEY_B, _ADDR_B);
        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        _map.removeUintToAddress(0, _KEY_C);

        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        _map.setUintToAddress(0, _KEY_B, _ADDR_B);

        _map.setUintToAddress(0, _KEY_C, _ADDR_C);
        _map.removeUintToAddress(0, _KEY_A);

        _map.setUintToAddress(0, _KEY_A, _ADDR_A);
        _map.removeUintToAddress(0, _KEY_B);

        _assertUintToAddressMembers(_toUintArray(_KEY_A, _KEY_C), _toAddressArray(_ADDR_A, _ADDR_C));
    }

    // Bytes32ToBytes32Map
    function testBytes32ToBytes32StartsEmpty() public {
        assertEq(_map.containsBytes32ToBytes32(0, _B32_A), false);
        _assertBytes32ToBytes32Members(new bytes32[](0), new bytes32[](0));
    }

    function testBytes32ToBytes32SetAdd() public {
        assertEq(_map.setBytes32ToBytes32(0, _B32_A, _B32_B), true);
        _assertBytes32ToBytes32Members(_toBytes32Array(_B32_A), _toBytes32Array(_B32_B));
    }

    function testBytes32ToBytes32SetUpdate() public {
        _map.setBytes32ToBytes32(0, _B32_A, _B32_B);
        assertEq(_map.setBytes32ToBytes32(0, _B32_A, _B32_C), false);
        _assertBytes32ToBytes32Members(_toBytes32Array(_B32_A), _toBytes32Array(_B32_C));
    }

    function testBytes32ToBytes32Remove() public {
        _map.setBytes32ToBytes32(0, _B32_A, _B32_B);
        assertEq(_map.removeBytes32ToBytes32(0, _B32_A), true);
        _assertBytes32ToBytes32Members(new bytes32[](0), new bytes32[](0));
    }

    function testBytes32ToBytes32TryGetAndGet() public {
        _map.setBytes32ToBytes32(0, _B32_A, _B32_B);
        (bool ok, bytes32 value) = _map.tryGetBytes32ToBytes32(0, _B32_A);
        assertEq(ok, true);
        assertEq(value, _B32_B);

        (bool okMissing, bytes32 valueMissing) = _map.tryGetBytes32ToBytes32(0, _B32_C);
        assertEq(okMissing, false);
        assertEq(valueMissing, bytes32(0));

        assertEq(_map.getBytes32ToBytes32(0, _B32_A), _B32_B);

        vm.expectRevert(bytes("EnumerableMap: nonexistent key"));
        _map.getBytes32ToBytes32(0, _B32_C);

        vm.expectRevert(bytes("custom error string"));
        _map.getBytes32ToBytes32(0, _B32_C, "custom error string");
    }

    // UintToUintMap
    function testUintToUintStartsEmpty() public {
        assertEq(_map.containsUintToUint(0, _KEY_A), false);
        _assertUintToUintMembers(new uint256[](0), new uint256[](0));
    }

    function testUintToUintSetAdd() public {
        assertEq(_map.setUintToUint(0, _KEY_A, _KEY_A + 1332), true);
        _assertUintToUintMembers(_toUintArray(_KEY_A), _toUintArray(_KEY_A + 1332));
    }

    function testUintToUintSetUpdate() public {
        _map.setUintToUint(0, _KEY_A, _KEY_A + 1332);
        assertEq(_map.setUintToUint(0, _KEY_A, _KEY_B + 1332), false);
        _assertUintToUintMembers(_toUintArray(_KEY_A), _toUintArray(_KEY_B + 1332));
    }

    function testUintToUintRemove() public {
        _map.setUintToUint(0, _KEY_A, _KEY_A + 1332);
        assertEq(_map.removeUintToUint(0, _KEY_A), true);
        _assertUintToUintMembers(new uint256[](0), new uint256[](0));
    }

    function testUintToUintTryGetAndGet() public {
        _map.setUintToUint(0, _KEY_A, _KEY_A + 1332);
        (bool ok, uint256 value) = _map.tryGetUintToUint(0, _KEY_A);
        assertEq(ok, true);
        assertEq(value, _KEY_A + 1332);

        (bool okMissing, uint256 valueMissing) = _map.tryGetUintToUint(0, _KEY_B);
        assertEq(okMissing, false);
        assertEq(valueMissing, 0);

        assertEq(_map.getUintToUint(0, _KEY_A), _KEY_A + 1332);

        vm.expectRevert(bytes("EnumerableMap: nonexistent key"));
        _map.getUintToUint(0, _KEY_B);

        vm.expectRevert(bytes("custom error string"));
        _map.getUintToUint(0, _KEY_B, "custom error string");
    }

    // Bytes32ToUintMap
    function testBytes32ToUintStartsEmpty() public {
        assertEq(_map.containsBytes32ToUint(0, _B32_A), false);
        _assertBytes32ToUintMembers(new bytes32[](0), new uint256[](0));
    }

    function testBytes32ToUintSetAdd() public {
        assertEq(_map.setBytes32ToUint(0, _B32_A, _KEY_A), true);
        _assertBytes32ToUintMembers(_toBytes32Array(_B32_A), _toUintArray(_KEY_A));
    }

    function testBytes32ToUintSetUpdate() public {
        _map.setBytes32ToUint(0, _B32_A, _KEY_A);
        assertEq(_map.setBytes32ToUint(0, _B32_A, _KEY_B), false);
        _assertBytes32ToUintMembers(_toBytes32Array(_B32_A), _toUintArray(_KEY_B));
    }

    function testBytes32ToUintRemove() public {
        _map.setBytes32ToUint(0, _B32_A, _KEY_A);
        assertEq(_map.removeBytes32ToUint(0, _B32_A), true);
        _assertBytes32ToUintMembers(new bytes32[](0), new uint256[](0));
    }

    function testBytes32ToUintTryGetAndGet() public {
        _map.setBytes32ToUint(0, _B32_A, _KEY_A);
        (bool ok, uint256 value) = _map.tryGetBytes32ToUint(0, _B32_A);
        assertEq(ok, true);
        assertEq(value, _KEY_A);

        (bool okMissing, uint256 valueMissing) = _map.tryGetBytes32ToUint(0, _B32_B);
        assertEq(okMissing, false);
        assertEq(valueMissing, 0);

        assertEq(_map.getBytes32ToUint(0, _B32_A), _KEY_A);

        vm.expectRevert(bytes("EnumerableMap: nonexistent key"));
        _map.getBytes32ToUint(0, _B32_B);

        vm.expectRevert(bytes("custom error string"));
        _map.getBytes32ToUint(0, _B32_B, "custom error string");
    }

    function _assertAddressToUintMembers(address[] memory keys, uint256[] memory values) private {
        assertEq(keys.length, values.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            assertEq(_map.containsAddressToUint(0, keys[i]), true);
            assertEq(_map.getAddressToUint(0, keys[i]), values[i]);
        }
        assertEq(_map.lengthAddressToUint(0), keys.length);

        for (uint256 i = 0; i < keys.length; ++i) {
            (address key, uint256 value) = _map.atAddressToUint(0, i);
            (bool found, uint256 idx) = _indexOfAddress(keys, key);
            assertEq(found, true);
            assertEq(values[idx], value);
        }

        address[] memory returnedKeys = _map.keysAddressToUint(0);
        _assertSameAddressMembers(returnedKeys, keys);
    }

    function _assertUintToAddressMembers(uint256[] memory keys, address[] memory values) private {
        assertEq(keys.length, values.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            assertEq(_map.containsUintToAddress(0, keys[i]), true);
            assertEq(_map.getUintToAddress(0, keys[i]), values[i]);
        }
        assertEq(_map.lengthUintToAddress(0), keys.length);

        for (uint256 i = 0; i < keys.length; ++i) {
            (uint256 key, address value) = _map.atUintToAddress(0, i);
            (bool found, uint256 idx) = _indexOfUint(keys, key);
            assertEq(found, true);
            assertEq(values[idx], value);
        }

        uint256[] memory returnedKeys = _map.keysUintToAddress(0);
        _assertSameUintMembers(returnedKeys, keys);
    }

    function _assertBytes32ToBytes32Members(bytes32[] memory keys, bytes32[] memory values) private {
        assertEq(keys.length, values.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            assertEq(_map.containsBytes32ToBytes32(0, keys[i]), true);
            assertEq(_map.getBytes32ToBytes32(0, keys[i]), values[i]);
        }
        assertEq(_map.lengthBytes32ToBytes32(0), keys.length);

        for (uint256 i = 0; i < keys.length; ++i) {
            (bytes32 key, bytes32 value) = _map.atBytes32ToBytes32(0, i);
            (bool found, uint256 idx) = _indexOfBytes32(keys, key);
            assertEq(found, true);
            assertEq(values[idx], value);
        }

        bytes32[] memory returnedKeys = _map.keysBytes32ToBytes32(0);
        _assertSameBytes32Members(returnedKeys, keys);
    }

    function _assertUintToUintMembers(uint256[] memory keys, uint256[] memory values) private {
        assertEq(keys.length, values.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            assertEq(_map.containsUintToUint(0, keys[i]), true);
            assertEq(_map.getUintToUint(0, keys[i]), values[i]);
        }
        assertEq(_map.lengthUintToUint(0), keys.length);

        for (uint256 i = 0; i < keys.length; ++i) {
            (uint256 key, uint256 value) = _map.atUintToUint(0, i);
            (bool found, uint256 idx) = _indexOfUint(keys, key);
            assertEq(found, true);
            assertEq(values[idx], value);
        }

        uint256[] memory returnedKeys = _map.keysUintToUint(0);
        _assertSameUintMembers(returnedKeys, keys);
    }

    function _assertBytes32ToUintMembers(bytes32[] memory keys, uint256[] memory values) private {
        assertEq(keys.length, values.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            assertEq(_map.containsBytes32ToUint(0, keys[i]), true);
            assertEq(_map.getBytes32ToUint(0, keys[i]), values[i]);
        }
        assertEq(_map.lengthBytes32ToUint(0), keys.length);

        for (uint256 i = 0; i < keys.length; ++i) {
            (bytes32 key, uint256 value) = _map.atBytes32ToUint(0, i);
            (bool found, uint256 idx) = _indexOfBytes32(keys, key);
            assertEq(found, true);
            assertEq(values[idx], value);
        }

        bytes32[] memory returnedKeys = _map.keysBytes32ToUint(0);
        _assertSameBytes32Members(returnedKeys, keys);
    }

    function _indexOfAddress(address[] memory items, address target) private pure returns (bool, uint256) {
        for (uint256 i = 0; i < items.length; ++i) {
            if (items[i] == target) return (true, i);
        }
        return (false, 0);
    }

    function _indexOfUint(uint256[] memory items, uint256 target) private pure returns (bool, uint256) {
        for (uint256 i = 0; i < items.length; ++i) {
            if (items[i] == target) return (true, i);
        }
        return (false, 0);
    }

    function _indexOfBytes32(bytes32[] memory items, bytes32 target) private pure returns (bool, uint256) {
        for (uint256 i = 0; i < items.length; ++i) {
            if (items[i] == target) return (true, i);
        }
        return (false, 0);
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

    function _toBytes32Array(bytes32 a) private pure returns (bytes32[] memory arr) {
        arr = new bytes32[](1);
        arr[0] = a;
    }

    function _toBytes32Array(bytes32 a, bytes32 b) private pure returns (bytes32[] memory arr) {
        arr = new bytes32[](2);
        arr[0] = a;
        arr[1] = b;
    }
}
