// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/StorageSlot.sol";

contract StorageSlotMock {
    using StorageSlot for *;

    function setBoolean(bytes32 slot, bool value) public {
        slot.getBooleanSlot().value = value;
    }

    function setAddress(bytes32 slot, address value) public {
        slot.getAddressSlot().value = value;
    }

    function setBytes32(bytes32 slot, bytes32 value) public {
        slot.getBytes32Slot().value = value;
    }

    function setUint256(bytes32 slot, uint256 value) public {
        slot.getUint256Slot().value = value;
    }

    function getBoolean(bytes32 slot) public view returns (bool) {
        return slot.getBooleanSlot().value;
    }

    function getAddress(bytes32 slot) public view returns (address) {
        return slot.getAddressSlot().value;
    }

    function getBytes32(bytes32 slot) public view returns (bytes32) {
        return slot.getBytes32Slot().value;
    }

    function getUint256(bytes32 slot) public view returns (uint256) {
        return slot.getUint256Slot().value;
    }

    mapping(uint256 => string) public stringMap;

    function setString(bytes32 slot, string calldata value) public {
        slot.getStringSlot().value = value;
    }

    function setStringStorage(uint256 key, string calldata value) public {
        stringMap[key].getStringSlot().value = value;
    }

    function getString(bytes32 slot) public view returns (string memory) {
        return slot.getStringSlot().value;
    }

    function getStringStorage(uint256 key) public view returns (string memory) {
        return stringMap[key].getStringSlot().value;
    }

    mapping(uint256 => bytes) public bytesMap;

    function setBytes(bytes32 slot, bytes calldata value) public {
        slot.getBytesSlot().value = value;
    }

    function setBytesStorage(uint256 key, bytes calldata value) public {
        bytesMap[key].getBytesSlot().value = value;
    }

    function getBytes(bytes32 slot) public view returns (bytes memory) {
        return slot.getBytesSlot().value;
    }

    function getBytesStorage(uint256 key) public view returns (bytes memory) {
        return bytesMap[key].getBytesSlot().value;
    }
}

contract StorageSlotTest is Test {
    StorageSlotMock private _store;
    bytes32 private _slot;
    bytes32 private _otherSlot;

    function setUp() public {
        _store = new StorageSlotMock();
        _slot = keccak256(abi.encodePacked("some.storage.slot"));
        _otherSlot = keccak256(abi.encodePacked("some.other.storage.slot"));
    }

    function testBooleanStorageSlotSet() public {
        _store.setBoolean(_slot, true);
    }

    function testBooleanStorageSlotGetFromRightSlot() public {
        _store.setBoolean(_slot, true);
        assertEq(_store.getBoolean(_slot), true);
    }

    function testBooleanStorageSlotGetFromOtherSlot() public {
        _store.setBoolean(_slot, true);
        assertEq(_store.getBoolean(_otherSlot), false);
    }

    function testAddressStorageSlotSet() public {
        _store.setAddress(_slot, address(0x1234));
    }

    function testAddressStorageSlotGetFromRightSlot() public {
        address value = address(0x1234);
        _store.setAddress(_slot, value);
        assertEq(_store.getAddress(_slot), value);
    }

    function testAddressStorageSlotGetFromOtherSlot() public {
        _store.setAddress(_slot, address(0x1234));
        assertEq(_store.getAddress(_otherSlot), address(0));
    }

    function testBytes32StorageSlotSet() public {
        bytes32 value = keccak256(abi.encodePacked("some byte32 value"));
        _store.setBytes32(_slot, value);
    }

    function testBytes32StorageSlotGetFromRightSlot() public {
        bytes32 value = keccak256(abi.encodePacked("some byte32 value"));
        _store.setBytes32(_slot, value);
        assertEq(_store.getBytes32(_slot), value);
    }

    function testBytes32StorageSlotGetFromOtherSlot() public {
        bytes32 value = keccak256(abi.encodePacked("some byte32 value"));
        _store.setBytes32(_slot, value);
        assertEq(_store.getBytes32(_otherSlot), bytes32(0));
    }

    function testUint256StorageSlotSet() public {
        _store.setUint256(_slot, 1742);
    }

    function testUint256StorageSlotGetFromRightSlot() public {
        _store.setUint256(_slot, 1742);
        assertEq(_store.getUint256(_slot), 1742);
    }

    function testUint256StorageSlotGetFromOtherSlot() public {
        _store.setUint256(_slot, 1742);
        assertEq(_store.getUint256(_otherSlot), 0);
    }

    function testStringStorageSlotSet() public {
        _store.setString(_slot, "lorem ipsum");
    }

    function testStringStorageSlotGetFromRightSlot() public {
        _store.setString(_slot, "lorem ipsum");
        assertEq(_store.getString(_slot), "lorem ipsum");
    }

    function testStringStorageSlotGetFromOtherSlot() public {
        _store.setString(_slot, "lorem ipsum");
        assertEq(_store.getString(_otherSlot), "");
    }

    function testStringStoragePointerSet() public {
        _store.setStringStorage(uint256(_slot), "lorem ipsum");
    }

    function testStringStoragePointerGetFromRightSlot() public {
        uint256 key = uint256(_slot);
        _store.setStringStorage(key, "lorem ipsum");
        assertEq(_store.stringMap(key), "lorem ipsum");
        assertEq(_store.getStringStorage(key), "lorem ipsum");
    }

    function testStringStoragePointerGetFromOtherSlot() public {
        uint256 key = uint256(_otherSlot);
        _store.setStringStorage(uint256(_slot), "lorem ipsum");
        assertEq(_store.stringMap(key), "");
        assertEq(_store.getStringStorage(key), "");
    }

    function testBytesStorageSlotSet() public {
        bytes memory value = hex"00112233445566778899aabbccddeeff";
        _store.setBytes(_slot, value);
    }

    function testBytesStorageSlotGetFromRightSlot() public {
        bytes memory value = hex"00112233445566778899aabbccddeeff";
        _store.setBytes(_slot, value);
        assertEq(_store.getBytes(_slot), value);
    }

    function testBytesStorageSlotGetFromOtherSlot() public {
        bytes memory value = hex"00112233445566778899aabbccddeeff";
        _store.setBytes(_slot, value);
        assertEq(_store.getBytes(_otherSlot), bytes(""));
    }

    function testBytesStoragePointerSet() public {
        bytes memory value = hex"00112233445566778899aabbccddeeff";
        _store.setBytesStorage(uint256(_slot), value);
    }

    function testBytesStoragePointerGetFromRightSlot() public {
        uint256 key = uint256(_slot);
        bytes memory value = hex"00112233445566778899aabbccddeeff";
        _store.setBytesStorage(key, value);
        assertEq(_store.bytesMap(key), value);
        assertEq(_store.getBytesStorage(key), value);
    }

    function testBytesStoragePointerGetFromOtherSlot() public {
        uint256 key = uint256(_otherSlot);
        bytes memory value = hex"00112233445566778899aabbccddeeff";
        _store.setBytesStorage(uint256(_slot), value);
        assertEq(_store.bytesMap(key), bytes(""));
        assertEq(_store.getBytesStorage(key), bytes(""));
    }
}
