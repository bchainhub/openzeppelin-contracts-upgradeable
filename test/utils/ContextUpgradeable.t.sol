// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/mocks/ContextMockUpgradeable.sol";

contract ContextUpgradeableTest is Test {
    event Sender(address sender);
    event Data(bytes data, uint256 integerValue, string stringValue);

    ContextMockUpgradeable private _context;
    ContextMockCallerUpgradeable private _caller;
    address private _sender;

    function setUp() public {
        _context = new ContextMockUpgradeable();
        _caller = new ContextMockCallerUpgradeable();
        _sender = makeAddr("sender");
    }

    function testMsgSenderFromEOA() public {
        vm.expectEmit(false, false, false, true, address(_context));
        emit Sender(_sender);
        vm.prank(_sender);
        _context.msgSender();
    }

    function testMsgSenderFromContract() public {
        vm.expectEmit(false, false, false, true, address(_context));
        emit Sender(address(_caller));
        vm.prank(_sender);
        _caller.callSender(_context);
    }

    function testMsgDataFromEOA() public {
        uint256 integerValue = 42;
        string memory stringValue = "OpenZeppelin";
        bytes memory callData = abi.encodeWithSelector(_context.msgData.selector, integerValue, stringValue);

        vm.expectEmit(false, false, false, true, address(_context));
        emit Data(callData, integerValue, stringValue);
        vm.prank(_sender);
        _context.msgData(integerValue, stringValue);
    }

    function testMsgDataFromContract() public {
        uint256 integerValue = 42;
        string memory stringValue = "OpenZeppelin";
        bytes memory callData = abi.encodeWithSelector(_context.msgData.selector, integerValue, stringValue);

        vm.expectEmit(false, false, false, true, address(_context));
        emit Data(callData, integerValue, stringValue);
        vm.prank(_sender);
        _caller.callData(_context, integerValue, stringValue);
    }
}
