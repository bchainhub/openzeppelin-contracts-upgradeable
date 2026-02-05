// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/TimersUpgradeable.sol";

contract TimersTimestampImplUpgradeable {
    using TimersUpgradeable for TimersUpgradeable.Timestamp;

    TimersUpgradeable.Timestamp private _timer;

    function getDeadline() external view returns (uint64) {
        return _timer.getDeadline();
    }

    function setDeadline(uint64 deadline) external {
        _timer.setDeadline(deadline);
    }

    function reset() external {
        _timer.reset();
    }

    function isUnset() external view returns (bool) {
        return _timer.isUnset();
    }

    function isStarted() external view returns (bool) {
        return _timer.isStarted();
    }

    function isPending() external view returns (bool) {
        return _timer.isPending();
    }

    function isExpired() external view returns (bool) {
        return _timer.isExpired();
    }
}

contract TimersBlockNumberImplUpgradeable {
    using TimersUpgradeable for TimersUpgradeable.BlockNumber;

    TimersUpgradeable.BlockNumber private _timer;

    function getDeadline() external view returns (uint64) {
        return _timer.getDeadline();
    }

    function setDeadline(uint64 deadline) external {
        _timer.setDeadline(deadline);
    }

    function reset() external {
        _timer.reset();
    }

    function isUnset() external view returns (bool) {
        return _timer.isUnset();
    }

    function isStarted() external view returns (bool) {
        return _timer.isStarted();
    }

    function isPending() external view returns (bool) {
        return _timer.isPending();
    }

    function isExpired() external view returns (bool) {
        return _timer.isExpired();
    }
}

contract TimersTimestampUpgradeableTest is Test {
    TimersTimestampImplUpgradeable private _instance;

    function setUp() public {
        _instance = new TimersTimestampImplUpgradeable();
    }

    function testUnset() public {
        assertEq(_instance.getDeadline(), 0);
        assertEq(_instance.isUnset(), true);
        assertEq(_instance.isStarted(), false);
        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), false);
    }

    function testPending() public {
        uint64 nowTs = uint64(block.timestamp);
        _instance.setDeadline(nowTs + 100);

        assertEq(_instance.getDeadline(), nowTs + 100);
        assertEq(_instance.isUnset(), false);
        assertEq(_instance.isStarted(), true);
        assertEq(_instance.isPending(), true);
        assertEq(_instance.isExpired(), false);
    }

    function testExpired() public {
        uint64 nowTs = uint64(block.timestamp);
        uint64 past = nowTs > 100 ? nowTs - 100 : 1;
        _instance.setDeadline(past);

        assertEq(_instance.getDeadline(), past);
        assertEq(_instance.isUnset(), false);
        assertEq(_instance.isStarted(), true);
        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), true);
    }

    function testReset() public {
        _instance.reset();
        assertEq(_instance.getDeadline(), 0);
        assertEq(_instance.isUnset(), true);
        assertEq(_instance.isStarted(), false);
        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), false);
    }

    function testFastForward() public {
        uint64 nowTs = uint64(block.timestamp);
        _instance.setDeadline(nowTs + 100);

        assertEq(_instance.isPending(), true);
        assertEq(_instance.isExpired(), false);

        vm.warp(nowTs + 100);

        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), true);
    }
}

contract TimersBlockNumberUpgradeableTest is Test {
    TimersBlockNumberImplUpgradeable private _instance;

    function setUp() public {
        _instance = new TimersBlockNumberImplUpgradeable();
    }

    function testUnset() public {
        assertEq(_instance.getDeadline(), 0);
        assertEq(_instance.isUnset(), true);
        assertEq(_instance.isStarted(), false);
        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), false);
    }

    function testPending() public {
        uint64 nowBlock = uint64(block.number);
        _instance.setDeadline(nowBlock + 3);

        assertEq(_instance.getDeadline(), nowBlock + 3);
        assertEq(_instance.isUnset(), false);
        assertEq(_instance.isStarted(), true);
        assertEq(_instance.isPending(), true);
        assertEq(_instance.isExpired(), false);
    }

    function testExpired() public {
        uint64 nowBlock = uint64(block.number);
        uint64 past = nowBlock > 3 ? nowBlock - 3 : 1;
        _instance.setDeadline(past);

        assertEq(_instance.getDeadline(), past);
        assertEq(_instance.isUnset(), false);
        assertEq(_instance.isStarted(), true);
        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), true);
    }

    function testReset() public {
        _instance.reset();
        assertEq(_instance.getDeadline(), 0);
        assertEq(_instance.isUnset(), true);
        assertEq(_instance.isStarted(), false);
        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), false);
    }

    function testFastForward() public {
        uint64 nowBlock = uint64(block.number);
        _instance.setDeadline(nowBlock + 3);

        assertEq(_instance.isPending(), true);
        assertEq(_instance.isExpired(), false);

        vm.roll(nowBlock + 3);

        assertEq(_instance.isPending(), false);
        assertEq(_instance.isExpired(), true);
    }
}
