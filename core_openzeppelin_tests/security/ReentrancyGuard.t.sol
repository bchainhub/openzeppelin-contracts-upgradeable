// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/mocks/ReentrancyMock.sol";
import "../../src/mocks/ReentrancyAttack.sol";

contract ReentrancyGuardTest is Test {
    ReentrancyMock private _mock;

    function setUp() public {
        _mock = new ReentrancyMock();
        assertEq(_mock.counter(), 0);
    }

    function testNonReentrantCanBeCalled() public {
        assertEq(_mock.counter(), 0);
        _mock.callback();
        assertEq(_mock.counter(), 1);
    }

    function testDoesNotAllowRemoteCallback() public {
        ReentrancyAttack attacker = new ReentrancyAttack();
        vm.expectRevert(bytes("ReentrancyAttack: failed call"));
        _mock.countAndCall(attacker);
    }

    function testGuardedEnteredIsTrueWhenGuarded() public {
        _mock.guardedCheckEntered();
    }

    function testGuardedEnteredIsFalseWhenUnguarded() public {
        _mock.unguardedCheckNotEntered();
    }

    function testDoesNotAllowLocalRecursion() public {
        vm.expectRevert(bytes("ReentrancyGuard: reentrant call"));
        _mock.countLocalRecursive(10);
    }

    function testDoesNotAllowIndirectLocalRecursion() public {
        vm.expectRevert(bytes("ReentrancyMock: failed call"));
        _mock.countThisRecursive(10);
    }
}
