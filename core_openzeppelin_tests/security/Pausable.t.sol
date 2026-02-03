// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/mocks/PausableMock.sol";

contract PausableTest is Test {
    PausableMock private _pausable;

    event Paused(address account);
    event Unpaused(address account);

    function setUp() public {
        _pausable = new PausableMock();
    }

    function testStartsUnpaused() public {
        assertEq(_pausable.paused(), false);
    }

    function testNormalProcessWhenUnpaused() public {
        assertEq(_pausable.count(), 0);
        _pausable.normalProcess();
        assertEq(_pausable.count(), 1);
    }

    function testCannotDrasticMeasureWhenUnpaused() public {
        vm.expectRevert(bytes("Pausable: not paused"));
        _pausable.drasticMeasure();
        assertEq(_pausable.drasticMeasureTaken(), false);
    }

    function testPauseEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Paused(address(this));
        _pausable.pause();
    }

    function testCannotNormalProcessWhenPaused() public {
        _pausable.pause();
        vm.expectRevert(bytes("Pausable: paused"));
        _pausable.normalProcess();
    }

    function testDrasticMeasureWhenPaused() public {
        _pausable.pause();
        _pausable.drasticMeasure();
        assertEq(_pausable.drasticMeasureTaken(), true);
    }

    function testRevertsWhenRepausing() public {
        _pausable.pause();
        vm.expectRevert(bytes("Pausable: paused"));
        _pausable.pause();
    }

    function testUnpauseEmitsEvent() public {
        _pausable.pause();
        vm.expectEmit(true, false, false, true);
        emit Unpaused(address(this));
        _pausable.unpause();
    }

    function testResumeNormalProcessAfterUnpause() public {
        _pausable.pause();
        _pausable.unpause();
        assertEq(_pausable.count(), 0);
        _pausable.normalProcess();
        assertEq(_pausable.count(), 1);
    }

    function testPreventDrasticMeasureAfterUnpause() public {
        _pausable.pause();
        _pausable.unpause();
        vm.expectRevert(bytes("Pausable: not paused"));
        _pausable.drasticMeasure();
    }

    function testRevertsWhenReunpausing() public {
        _pausable.pause();
        _pausable.unpause();
        vm.expectRevert(bytes("Pausable: not paused"));
        _pausable.unpause();
    }
}
