// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/security/ReentrancyGuardUpgradeable.sol";
import "../../src/proxy/utils/Initializable.sol";
import "../../src/utils/ContextUpgradeable.sol";

contract ReentrancyAttackUpgradeable is Initializable, ContextUpgradeable {
    function initialize() external initializer {}

    function callSender(bytes4 data) public {
        (bool success,) = _msgSender().call(abi.encodeWithSelector(data));
        require(success, "ReentrancyAttack: failed call");
    }
}

contract ReentrancyMockUpgradeable is Initializable, ReentrancyGuardUpgradeable {
    uint256 public counter;

    function initialize() external initializer {
        __ReentrancyGuard_init();
        counter = 0;
    }

    function callback() external nonReentrant {
        _count();
    }

    function countLocalRecursive(uint256 n) public nonReentrant {
        if (n > 0) {
            _count();
            countLocalRecursive(n - 1);
        }
    }

    function countThisRecursive(uint256 n) public nonReentrant {
        if (n > 0) {
            _count();
            (bool success,) = address(this).call(abi.encodeWithSignature("countThisRecursive(uint256)", n - 1));
            require(success, "ReentrancyMock: failed call");
        }
    }

    function countAndCall(ReentrancyAttackUpgradeable attacker) public nonReentrant {
        _count();
        bytes4 func = bytes4(keccak256("callback()"));
        attacker.callSender(func);
    }

    function _count() private {
        counter += 1;
    }

    function guardedCheckEntered() public nonReentrant {
        require(_reentrancyGuardEntered());
    }

    function unguardedCheckNotEntered() public view {
        require(!_reentrancyGuardEntered());
    }
}

contract ReentrancyGuardUpgradeableTest is Test {
    ReentrancyMockUpgradeable private _mock;

    function setUp() public {
        _mock = new ReentrancyMockUpgradeable();
        _mock.initialize();
        assertEq(_mock.counter(), 0);
    }

    function testNonReentrantCanBeCalled() public {
        assertEq(_mock.counter(), 0);
        _mock.callback();
        assertEq(_mock.counter(), 1);
    }

    function testDoesNotAllowRemoteCallback() public {
        ReentrancyAttackUpgradeable attacker = new ReentrancyAttackUpgradeable();
        attacker.initialize();

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
