// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (utils/structs/Heap.sol)

pragma solidity ^1.1.2;

import "../math/MathUpgradeable.sol";
import "../ComparatorsUpgradeable.sol";
import "../ArraysUpgradeable.sol";
import "../PanicUpgradeable.sol";
import "../StorageSlotUpgradeable.sol";

/**
 * @dev Library for managing binary heap that can be used as priority queue.
 */
library HeapUpgradeable {
    using ArraysUpgradeable for *;
    using MathUpgradeable for *;

    struct Uint256Heap {
        uint256[] tree;
    }

    function peek(Uint256Heap storage self) internal view returns (uint256) {
        return self.tree[0];
    }

    function pop(Uint256Heap storage self) internal returns (uint256) {
        return pop(self, ComparatorsUpgradeable.lt);
    }

    function pop(Uint256Heap storage self, function(uint256, uint256) view returns (bool) comp)
        internal
        returns (uint256)
    {
        unchecked {
            uint256 size = length(self);
            if (size == 0) PanicUpgradeable.panic(PanicUpgradeable.EMPTY_ARRAY_POP);

            uint256 rootValue = self.tree.unsafeAccess(0).value;

            if (size == 1) {
                self.tree.pop();
            } else {
                uint256 lastValue = self.tree.unsafeAccess(size - 1).value;
                self.tree.unsafeAccess(0).value = lastValue;
                self.tree.pop();
                _siftDown(self, size - 1, 0, lastValue, comp);
            }

            return rootValue;
        }
    }

    function insert(Uint256Heap storage self, uint256 value) internal {
        insert(self, value, ComparatorsUpgradeable.lt);
    }

    function insert(Uint256Heap storage self, uint256 value, function(uint256, uint256) view returns (bool) comp)
        internal
    {
        uint256 size = length(self);
        self.tree.push(value);
        _siftUp(self, size, value, comp);
    }

    function replace(Uint256Heap storage self, uint256 newValue) internal returns (uint256) {
        return replace(self, newValue, ComparatorsUpgradeable.lt);
    }

    function replace(Uint256Heap storage self, uint256 newValue, function(uint256, uint256) view returns (bool) comp)
        internal
        returns (uint256)
    {
        uint256 size = length(self);
        if (size == 0) PanicUpgradeable.panic(PanicUpgradeable.EMPTY_ARRAY_POP);

        uint256 oldValue = self.tree.unsafeAccess(0).value;
        self.tree.unsafeAccess(0).value = newValue;
        _siftDown(self, size, 0, newValue, comp);
        return oldValue;
    }

    function length(Uint256Heap storage self) internal view returns (uint256) {
        return self.tree.length;
    }

    function clear(Uint256Heap storage self) internal {
        self.tree.unsafeSetLength(0);
    }

    function _swap(Uint256Heap storage self, uint256 i, uint256 j) private {
        StorageSlotUpgradeable.Uint256Slot storage ni = self.tree.unsafeAccess(i);
        StorageSlotUpgradeable.Uint256Slot storage nj = self.tree.unsafeAccess(j);
        (ni.value, nj.value) = (nj.value, ni.value);
    }

    function _siftDown(
        Uint256Heap storage self,
        uint256 size,
        uint256 index,
        uint256 value,
        function(uint256, uint256) view returns (bool) comp
    ) private {
        unchecked {
            if (index >= type(uint256).max / 2) return;

            uint256 lIndex = 2 * index + 1;
            uint256 rIndex = 2 * index + 2;

            if (rIndex < size) {
                uint256 lValue = self.tree.unsafeAccess(lIndex).value;
                uint256 rValue = self.tree.unsafeAccess(rIndex).value;

                if (comp(lValue, value) || comp(rValue, value)) {
                    uint256 cIndex = comp(lValue, rValue).ternary(lIndex, rIndex);
                    _swap(self, index, cIndex);
                    _siftDown(self, size, cIndex, value, comp);
                }
            } else if (lIndex < size) {
                uint256 lValue = self.tree.unsafeAccess(lIndex).value;
                if (comp(lValue, value)) {
                    _swap(self, index, lIndex);
                    _siftDown(self, size, lIndex, value, comp);
                }
            }
        }
    }

    function _siftUp(
        Uint256Heap storage self,
        uint256 index,
        uint256 value,
        function(uint256, uint256) view returns (bool) comp
    ) private {
        unchecked {
            while (index > 0) {
                uint256 parentIndex = (index - 1) / 2;
                uint256 parentValue = self.tree.unsafeAccess(parentIndex).value;

                if (comp(parentValue, value)) {
                    break;
                }

                _swap(self, index, parentIndex);
                index = parentIndex;
            }
        }
    }
}
