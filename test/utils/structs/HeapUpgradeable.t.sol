// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/math/MathUpgradeable.sol";
import "../../../src/utils/structs/HeapUpgradeable.sol";
import "../../../src/utils/ComparatorsUpgradeable.sol";

contract Uint256HeapUpgradeableTest is Test {
    using HeapUpgradeable for HeapUpgradeable.Uint256Heap;

    bytes4 private constant _CORE_PANIC_SELECTOR = 0x4b1f2ce3;

    HeapUpgradeable.Uint256Heap internal heap;

    function _validateHeap(function(uint256, uint256) view returns (bool) comp) internal {
        for (uint32 i = 1; i < heap.length(); ++i) {
            assertFalse(comp(heap.tree[i], heap.tree[(i - 1) / 2]));
        }
    }

    function testFuzz(uint256[] calldata input) public {
        vm.assume(input.length < 0x20);
        assertEq(heap.length(), 0);

        uint256 min = type(uint256).max;
        for (uint256 i = 0; i < input.length; ++i) {
            heap.insert(input[i]);
            assertEq(heap.length(), i + 1);
            _validateHeap(ComparatorsUpgradeable.lt);
            min = MathUpgradeable.min(min, input[i]);
            assertEq(heap.peek(), min);
        }

        uint256 max = 0;
        for (uint256 i = 0; i < input.length; ++i) {
            uint256 top = heap.peek();
            uint256 popValue = heap.pop();
            assertEq(heap.length(), input.length - i - 1);
            _validateHeap(ComparatorsUpgradeable.lt);
            assertEq(popValue, top);
            assertGe(popValue, max);
            max = popValue;
        }
    }

    function testFuzzGt(uint256[] calldata input) public {
        vm.assume(input.length < 0x20);
        assertEq(heap.length(), 0);

        uint256 max = 0;
        for (uint256 i = 0; i < input.length; ++i) {
            heap.insert(input[i], ComparatorsUpgradeable.gt);
            assertEq(heap.length(), i + 1);
            _validateHeap(ComparatorsUpgradeable.gt);
            max = MathUpgradeable.max(max, input[i]);
            assertEq(heap.peek(), max);
        }

        uint256 min = type(uint256).max;
        for (uint256 i = 0; i < input.length; ++i) {
            uint256 top = heap.peek();
            uint256 popValue = heap.pop(ComparatorsUpgradeable.gt);
            assertEq(heap.length(), input.length - i - 1);
            _validateHeap(ComparatorsUpgradeable.gt);
            assertEq(popValue, top);
            assertLe(popValue, min);
            min = popValue;
        }
    }

    function testReplaceUpdatesRootAndReturnsPreviousRoot() public {
        heap.insert(10);
        heap.insert(20);
        heap.insert(30);

        uint256 oldValue = heap.replace(25);

        assertEq(oldValue, 10);
        assertEq(heap.length(), 3);
        assertEq(heap.peek(), 20);
        _validateHeap(ComparatorsUpgradeable.lt);
    }

    function testReplaceUpdatesRootAndReturnsPreviousRootGt() public {
        heap.insert(10, ComparatorsUpgradeable.gt);
        heap.insert(20, ComparatorsUpgradeable.gt);
        heap.insert(30, ComparatorsUpgradeable.gt);

        uint256 oldValue = heap.replace(25, ComparatorsUpgradeable.gt);

        assertEq(oldValue, 30);
        assertEq(heap.length(), 3);
        assertEq(heap.peek(), 25);
        _validateHeap(ComparatorsUpgradeable.gt);
    }

    function testClearResetsLength() public {
        heap.insert(10);
        heap.insert(20);
        heap.insert(30);

        heap.clear();

        assertEq(heap.length(), 0);

        heap.insert(5);
        assertEq(heap.length(), 1);
        assertEq(heap.peek(), 5);
    }

    function testPopEmptyRevertsWithCorePanic() public {
        vm.expectRevert(abi.encodeWithSelector(_CORE_PANIC_SELECTOR, 0x31));
        heap.pop();
    }

    function testReplaceEmptyRevertsWithCorePanic() public {
        vm.expectRevert(abi.encodeWithSelector(_CORE_PANIC_SELECTOR, 0x31));
        heap.replace(1);
    }
}
