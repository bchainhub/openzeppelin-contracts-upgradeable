// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/mocks/TimersTimestampImpl.sol";

contract TimersTimestampTest is Test {
    TimersTimestampImpl private _timer;
    uint64 private _now;

    function setUp() public {
        _timer = new TimersTimestampImpl();
        _now = uint64(block.timestamp);
    }

    function testUnset() public {
        assertEq(_timer.getDeadline(), 0);
        assertEq(_timer.isUnset(), true);
        assertEq(_timer.isStarted(), false);
        assertEq(_timer.isPending(), false);
        assertEq(_timer.isExpired(), false);
    }

    function testPending() public {
        _timer.setDeadline(_now + 100);
        assertEq(_timer.getDeadline(), _now + 100);
        assertEq(_timer.isUnset(), false);
        assertEq(_timer.isStarted(), true);
        assertEq(_timer.isPending(), true);
        assertEq(_timer.isExpired(), false);
    }

    function testExpired() public {
        uint64 past = _now > 100 ? _now - 100 : 1;
        _timer.setDeadline(past);
        assertEq(_timer.getDeadline(), past);
        assertEq(_timer.isUnset(), false);
        assertEq(_timer.isStarted(), true);
        assertEq(_timer.isPending(), false);
        assertEq(_timer.isExpired(), true);
    }

    function testReset() public {
        _timer.reset();
        assertEq(_timer.getDeadline(), 0);
        assertEq(_timer.isUnset(), true);
        assertEq(_timer.isStarted(), false);
        assertEq(_timer.isPending(), false);
        assertEq(_timer.isExpired(), false);
    }

    function testFastForward() public {
        _timer.setDeadline(_now + 100);
        assertEq(_timer.isPending(), true);
        assertEq(_timer.isExpired(), false);

        vm.warp(_now + 100);
        assertEq(_timer.isPending(), false);
        assertEq(_timer.isExpired(), true);
    }
}
