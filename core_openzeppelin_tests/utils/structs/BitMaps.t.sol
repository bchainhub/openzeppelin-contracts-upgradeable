// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/structs/BitMaps.sol";

contract BitMapsMock {
    using BitMaps for BitMaps.BitMap;

    mapping(uint256 => BitMaps.BitMap) private _maps;

    function get(uint256 mapId, uint256 index) external view returns (bool) {
        return _maps[mapId].get(index);
    }

    function setTo(uint256 mapId, uint256 index, bool value) external {
        _maps[mapId].setTo(index, value);
    }

    function set(uint256 mapId, uint256 index) external {
        _maps[mapId].set(index);
    }

    function unset(uint256 mapId, uint256 index) external {
        _maps[mapId].unset(index);
    }
}

contract BitMapsTest is Test {
    BitMapsMock private _bitmap;

    uint256 private constant _MAP_ID = 0;
    uint256 private constant _KEY_A = 7891;
    uint256 private constant _KEY_B = 451;
    uint256 private constant _KEY_C = 9592328;

    function setUp() public {
        _bitmap = new BitMapsMock();
    }

    function testStartsEmpty() public {
        assertEq(_bitmap.get(_MAP_ID, _KEY_A), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), false);
    }

    function testSetToTrue() public {
        _bitmap.setTo(_MAP_ID, _KEY_A, true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), false);
    }

    function testSetToFalse() public {
        _bitmap.setTo(_MAP_ID, _KEY_A, true);
        _bitmap.setTo(_MAP_ID, _KEY_A, false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), false);
    }

    function testSetToConsecutiveKeys() public {
        _bitmap.setTo(_MAP_ID, _KEY_A + 0, true);
        _bitmap.setTo(_MAP_ID, _KEY_A + 1, true);
        _bitmap.setTo(_MAP_ID, _KEY_A + 2, true);
        _bitmap.setTo(_MAP_ID, _KEY_A + 3, true);
        _bitmap.setTo(_MAP_ID, _KEY_A + 4, true);
        _bitmap.setTo(_MAP_ID, _KEY_A + 2, false);
        _bitmap.setTo(_MAP_ID, _KEY_A + 4, false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 0), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 1), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 2), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 3), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 4), false);
    }

    function testSetAddsKey() public {
        _bitmap.set(_MAP_ID, _KEY_A);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), false);
    }

    function testSetAddsSeveralKeys() public {
        _bitmap.set(_MAP_ID, _KEY_A);
        _bitmap.set(_MAP_ID, _KEY_B);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), false);
    }

    function testSetAddsConsecutiveKeys() public {
        _bitmap.set(_MAP_ID, _KEY_A + 0);
        _bitmap.set(_MAP_ID, _KEY_A + 1);
        _bitmap.set(_MAP_ID, _KEY_A + 3);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 0), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 1), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 2), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 3), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 4), false);
    }

    function testUnsetRemovesAddedKeys() public {
        _bitmap.set(_MAP_ID, _KEY_A);
        _bitmap.set(_MAP_ID, _KEY_B);
        _bitmap.unset(_MAP_ID, _KEY_A);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), false);
    }

    function testUnsetRemovesConsecutiveKeys() public {
        _bitmap.set(_MAP_ID, _KEY_A + 0);
        _bitmap.set(_MAP_ID, _KEY_A + 1);
        _bitmap.set(_MAP_ID, _KEY_A + 3);
        _bitmap.unset(_MAP_ID, _KEY_A + 1);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 0), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 1), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 2), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 3), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_A + 4), false);
    }

    function testUnsetAddsAndRemovesMultipleKeys() public {
        _bitmap.set(_MAP_ID, _KEY_A);
        _bitmap.set(_MAP_ID, _KEY_C);

        _bitmap.unset(_MAP_ID, _KEY_A);
        _bitmap.unset(_MAP_ID, _KEY_B);

        _bitmap.set(_MAP_ID, _KEY_B);

        _bitmap.set(_MAP_ID, _KEY_A);
        _bitmap.unset(_MAP_ID, _KEY_C);

        _bitmap.set(_MAP_ID, _KEY_A);
        _bitmap.set(_MAP_ID, _KEY_B);

        _bitmap.set(_MAP_ID, _KEY_C);
        _bitmap.unset(_MAP_ID, _KEY_A);

        _bitmap.set(_MAP_ID, _KEY_A);
        _bitmap.unset(_MAP_ID, _KEY_B);

        assertEq(_bitmap.get(_MAP_ID, _KEY_A), true);
        assertEq(_bitmap.get(_MAP_ID, _KEY_B), false);
        assertEq(_bitmap.get(_MAP_ID, _KEY_C), true);
    }
}
