// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/structs/DoubleEndedQueue.sol";

contract DoubleEndedQueueMock {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    mapping(uint256 => DoubleEndedQueue.Bytes32Deque) private _deques;

    function pushBack(uint256 dequeId, bytes32 value) external {
        _deques[dequeId].pushBack(value);
    }

    function popBack(uint256 dequeId) external returns (bytes32) {
        return _deques[dequeId].popBack();
    }

    function pushFront(uint256 dequeId, bytes32 value) external {
        _deques[dequeId].pushFront(value);
    }

    function popFront(uint256 dequeId) external returns (bytes32) {
        return _deques[dequeId].popFront();
    }

    function front(uint256 dequeId) external view returns (bytes32) {
        return _deques[dequeId].front();
    }

    function back(uint256 dequeId) external view returns (bytes32) {
        return _deques[dequeId].back();
    }

    function at(uint256 dequeId, uint256 index) external view returns (bytes32) {
        return _deques[dequeId].at(index);
    }

    function clear(uint256 dequeId) external {
        _deques[dequeId].clear();
    }

    function length(uint256 dequeId) external view returns (uint256) {
        return _deques[dequeId].length();
    }

    function empty(uint256 dequeId) external view returns (bool) {
        return _deques[dequeId].empty();
    }
}

contract DoubleEndedQueueTest is Test {
    DoubleEndedQueueMock private _deque;

    uint256 private constant _DEQUE_ID = 0;
    bytes32 private constant _BYTES_A = bytes32(uint256(0xdeadbeef));
    bytes32 private constant _BYTES_B = bytes32(uint256(0x0123456789));
    bytes32 private constant _BYTES_C = bytes32(uint256(0x42424242));
    bytes32 private constant _BYTES_D = bytes32(uint256(0x171717));

    function setUp() public {
        _deque = new DoubleEndedQueueMock();
    }

    function testWhenEmptyGetters() public {
        assertEq(_deque.empty(_DEQUE_ID), true);
        _assertContent(new bytes32[](0));
    }

    function testWhenEmptyRevertsOnAccess() public {
        vm.expectRevert(abi.encodeWithSignature("Empty()"));
        _deque.popBack(_DEQUE_ID);

        vm.expectRevert(abi.encodeWithSignature("Empty()"));
        _deque.popFront(_DEQUE_ID);

        vm.expectRevert(abi.encodeWithSignature("Empty()"));
        _deque.back(_DEQUE_ID);

        vm.expectRevert(abi.encodeWithSignature("Empty()"));
        _deque.front(_DEQUE_ID);
    }

    function testWhenNotEmptyGetters() public {
        _seedDeque();
        assertEq(_deque.empty(_DEQUE_ID), false);
        assertEq(_deque.length(_DEQUE_ID), 3);
        assertEq(_deque.front(_DEQUE_ID), _BYTES_A);
        assertEq(_deque.back(_DEQUE_ID), _BYTES_C);
        _assertContent(_toArray(_BYTES_A, _BYTES_B, _BYTES_C));
    }

    function testWhenNotEmptyOutOfBoundsAccess() public {
        _seedDeque();
        vm.expectRevert(abi.encodeWithSignature("OutOfBounds()"));
        _deque.at(_DEQUE_ID, 3);
    }

    function testPushFront() public {
        _seedDeque();
        _deque.pushFront(_DEQUE_ID, _BYTES_D);
        _assertContent(_toArray(_BYTES_D, _BYTES_A, _BYTES_B, _BYTES_C));
    }

    function testPushBack() public {
        _seedDeque();
        _deque.pushBack(_DEQUE_ID, _BYTES_D);
        _assertContent(_toArray(_BYTES_A, _BYTES_B, _BYTES_C, _BYTES_D));
    }

    function testPopFront() public {
        _seedDeque();
        bytes32 value = _deque.popFront(_DEQUE_ID);
        assertEq(value, _BYTES_A);
        _assertContent(_toArray(_BYTES_B, _BYTES_C));
    }

    function testPopBack() public {
        _seedDeque();
        bytes32 value = _deque.popBack(_DEQUE_ID);
        assertEq(value, _BYTES_C);
        _assertContent(_toArray(_BYTES_A, _BYTES_B));
    }

    function testClear() public {
        _seedDeque();
        _deque.clear(_DEQUE_ID);
        assertEq(_deque.empty(_DEQUE_ID), true);
        _assertContent(new bytes32[](0));
    }

    function _seedDeque() private {
        _deque.pushBack(_DEQUE_ID, _BYTES_B);
        _deque.pushFront(_DEQUE_ID, _BYTES_A);
        _deque.pushBack(_DEQUE_ID, _BYTES_C);
    }

    function _getContent() private returns (bytes32[] memory) {
        uint256 len = _deque.length(_DEQUE_ID);
        bytes32[] memory content = new bytes32[](len);
        for (uint256 i = 0; i < len; i++) {
            content[i] = _deque.at(_DEQUE_ID, i);
        }
        return content;
    }

    function _assertContent(bytes32[] memory expected) private {
        bytes32[] memory actual = _getContent();
        assertEq(actual.length, expected.length);
        for (uint256 i = 0; i < expected.length; i++) {
            assertEq(actual[i], expected[i]);
        }
    }

    function _toArray(bytes32 a) private pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](1);
        arr[0] = a;
        return arr;
    }

    function _toArray(bytes32 a, bytes32 b) private pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function _toArray(bytes32 a, bytes32 b, bytes32 c) private pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function _toArray(bytes32 a, bytes32 b, bytes32 c, bytes32 d) private pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](4);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        return arr;
    }
}
