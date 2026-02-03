// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/Counters.sol";

contract CountersMock {
    using Counters for Counters.Counter;

    mapping(uint256 => Counters.Counter) private _counters;

    function current(uint256 index) external view returns (uint256) {
        return _counters[index].current();
    }

    function increment(uint256 index) external {
        _counters[index].increment();
    }

    function decrement(uint256 index) external {
        _counters[index].decrement();
    }

    function reset(uint256 index) external {
        _counters[index].reset();
    }
}

contract CountersTest is Test {
    CountersMock private _counter;

    function setUp() public {
        _counter = new CountersMock();
    }

    function testStartsAtZero() public {
        assertEq(_counter.current(0), 0);
    }

    function testIncrementFromZero() public {
        _counter.increment(0);
        assertEq(_counter.current(0), 1);
    }

    function testIncrementMultipleTimes() public {
        _counter.increment(0);
        _counter.increment(0);
        _counter.increment(0);
        assertEq(_counter.current(0), 3);
    }

    function testDecrementFromOne() public {
        _counter.increment(0);
        assertEq(_counter.current(0), 1);

        _counter.decrement(0);
        assertEq(_counter.current(0), 0);
    }

    function testDecrementRevertsAtZero() public {
        _counter.increment(0);
        _counter.decrement(0);
        vm.expectRevert(bytes("Counter: decrement overflow"));
        _counter.decrement(0);
    }

    function testDecrementMultipleTimes() public {
        _counter.increment(0);
        _counter.increment(0);
        _counter.increment(0);
        assertEq(_counter.current(0), 3);

        _counter.decrement(0);
        _counter.decrement(0);
        _counter.decrement(0);
        assertEq(_counter.current(0), 0);
    }

    function testResetNullCounter() public {
        _counter.reset(0);
        assertEq(_counter.current(0), 0);
    }

    function testResetNonNullCounter() public {
        _counter.increment(0);
        assertEq(_counter.current(0), 1);

        _counter.reset(0);
        assertEq(_counter.current(0), 0);
    }
}
