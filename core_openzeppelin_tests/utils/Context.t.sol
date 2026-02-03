// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/Context.sol";

contract ContextMock is Context {
    function msgSender() public view returns (address) {
        return _msgSender();
    }

    function msgData(uint256 integerValue, string memory stringValue) public view returns (bytes memory, uint256, string memory) {
        bytes memory data = _msgData();
        return (data, integerValue, stringValue);
    }
}

contract ContextMockCaller {
    function callSender(ContextMock context) public view returns (address) {
        return context.msgSender();
    }

    function callData(
        ContextMock context,
        uint256 integerValue,
        string memory stringValue
    ) public view returns (bytes memory, uint256, string memory) {
        return context.msgData(integerValue, stringValue);
    }
}

contract ContextTest is Test {
    ContextMock private _context;
    ContextMockCaller private _caller;

    function setUp() public {
        _context = new ContextMock();
        _caller = new ContextMockCaller();
    }

    function testMsgSenderFromEOA() public {
        assertEq(_context.msgSender(), address(this));
    }

    function testMsgSenderFromContract() public {
        assertEq(_caller.callSender(_context), address(_caller));
    }

    function testMsgDataFromEOA() public {
        uint256 integerValue = 42;
        string memory stringValue = "OpenZeppelin";
        bytes memory expected = abi.encodeWithSelector(_context.msgData.selector, integerValue, stringValue);
        (bytes memory data, uint256 intValue, string memory strValue) = _context.msgData(integerValue, stringValue);
        assertEq(data, expected);
        assertEq(intValue, integerValue);
        assertEq(strValue, stringValue);
    }

    function testMsgDataFromContract() public {
        uint256 integerValue = 42;
        string memory stringValue = "OpenZeppelin";
        bytes memory expected = abi.encodeWithSelector(_context.msgData.selector, integerValue, stringValue);
        (bytes memory data, uint256 intValue, string memory strValue) =
            _caller.callData(_context, integerValue, stringValue);
        assertEq(data, expected);
        assertEq(intValue, integerValue);
        assertEq(strValue, stringValue);
    }
}
