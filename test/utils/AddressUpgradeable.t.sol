// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import {AddressUpgradeable} from "../../src/utils/AddressUpgradeable.sol";

contract AddressUpgradeableHarness {
    using AddressUpgradeable for address;

    receive() external payable {}

    function isContract(address account) external view returns (bool) {
        return AddressUpgradeable.isContract(account);
    }

    function sendValue(address payable recipient, uint256 amount) external {
        AddressUpgradeable.sendValue(recipient, amount);
    }

    function functionCall(address target, bytes memory data) external returns (bytes memory) {
        return AddressUpgradeable.functionCall(target, data);
    }

    function functionCallError(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external returns (bytes memory) {
        return AddressUpgradeable.functionCall(target, data, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) external payable returns (bytes memory) {
        return AddressUpgradeable.functionCallWithValue(target, data, value);
    }

    function functionCallWithValueError(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) external payable returns (bytes memory) {
        return AddressUpgradeable.functionCallWithValue(target, data, value, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) external view returns (bytes memory) {
        return AddressUpgradeable.functionStaticCall(target, data);
    }

    function functionStaticCallError(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external view returns (bytes memory) {
        return AddressUpgradeable.functionStaticCall(target, data, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) external returns (bytes memory) {
        return AddressUpgradeable.functionDelegateCall(target, data);
    }

    function functionDelegateCallError(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external returns (bytes memory) {
        return AddressUpgradeable.functionDelegateCall(target, data, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) external pure returns (bytes memory) {
        return AddressUpgradeable.verifyCallResult(success, returndata, errorMessage);
    }

    function readSlot(bytes32 slot) external view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }
}

contract EtherReceiverMockUpgradeable {
    bool private _acceptEther;

    function setAcceptEther(bool acceptEther) external {
        _acceptEther = acceptEther;
    }

    receive() external payable {
        if (!_acceptEther) {
            revert();
        }
    }
}

contract CallReceiverMockUpgradeable {
    uint256[] private _array;

    event MockFunctionCalled();
    event MockFunctionCalledWithArgs(uint256 a, uint256 b);

    function mockFunction() external payable returns (string memory) {
        emit MockFunctionCalled();
        return "0x1234";
    }

    function mockFunctionEmptyReturn() external payable {
        emit MockFunctionCalled();
    }

    function mockFunctionWithArgs(uint256 a, uint256 b) external payable returns (string memory) {
        emit MockFunctionCalledWithArgs(a, b);
        return "0x1234";
    }

    function mockFunctionNonPayable() external returns (string memory) {
        emit MockFunctionCalled();
        return "0x1234";
    }

    function mockStaticFunction() external pure returns (string memory) {
        return "0x1234";
    }

    function mockFunctionRevertsNoReason() external pure {
        revert();
    }

    function mockFunctionRevertsReason() external pure {
        revert("CallReceiverMock: reverting");
    }

    function mockFunctionThrows() external pure {
        assert(false);
    }

    function mockFunctionOutOfGas() external {
        for (uint256 i = 0; ; ++i) {
            _array.push(i);
        }
    }

    function mockFunctionWritesStorage(bytes32 slot, bytes32 value) external returns (string memory) {
        assembly {
            sstore(slot, value)
        }
        return "0x1234";
    }
}

contract AddressUpgradeableTest is Test {
    AddressUpgradeableHarness private _harness;
    CallReceiverMockUpgradeable private _callReceiver;
    address private _recipient;
    address private _other;

    function setUp() public {
        _harness = new AddressUpgradeableHarness();
        _callReceiver = new CallReceiverMockUpgradeable();
        _recipient = makeAddr("recipient");
        _other = makeAddr("other");
    }

    function testIsContractReturnsFalseForEoa() public {
        assertFalse(_harness.isContract(_other));
    }

    function testIsContractReturnsTrueForContract() public {
        assertTrue(_harness.isContract(address(_harness)));
    }

    function testSendValueSendsZeroWithoutFunds() public {
        uint256 beforeBalance = _other.balance;
        _harness.sendValue(payable(_other), 0);
        assertEq(_other.balance - beforeBalance, 0);
    }

    function testSendValueRevertsWithoutFundsForNonZero() public {
        vm.expectRevert(bytes("Address: insufficient balance"));
        _harness.sendValue(payable(_other), 1);
    }

    function testSendValueSendsNonZeroWhenFunded() public {
        uint256 amount = 1 ether;
        vm.deal(address(_harness), amount);
        uint256 beforeBalance = _recipient.balance;
        _harness.sendValue(payable(_recipient), amount - 1);
        assertEq(_recipient.balance - beforeBalance, amount - 1);
    }

    function testSendValueSendsWholeBalance() public {
        uint256 amount = 1 ether;
        vm.deal(address(_harness), amount);
        _harness.sendValue(payable(_recipient), amount);
        assertEq(address(_harness).balance, 0);
    }

    function testSendValueRevertsWhenSendingMoreThanBalance() public {
        vm.deal(address(_harness), 1 ether);
        vm.expectRevert(bytes("Address: insufficient balance"));
        _harness.sendValue(payable(_recipient), 1 ether + 1);
    }

    function testSendValueToContractRecipient() public {
        EtherReceiverMockUpgradeable recipient = new EtherReceiverMockUpgradeable();
        recipient.setAcceptEther(true);

        uint256 amount = 1 ether;
        vm.deal(address(_harness), amount);
        uint256 beforeBalance = address(recipient).balance;

        _harness.sendValue(payable(address(recipient)), amount);
        assertEq(address(recipient).balance - beforeBalance, amount);
    }

    function testSendValueRevertsOnRecipientRevert() public {
        EtherReceiverMockUpgradeable recipient = new EtherReceiverMockUpgradeable();
        recipient.setAcceptEther(false);

        vm.deal(address(_harness), 1 ether);
        vm.expectRevert(bytes("Address: unable to send value, recipient may have reverted"));
        _harness.sendValue(payable(address(recipient)), 1 ether);
    }

    function testFunctionCallWorks() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        bytes memory ret = _harness.functionCall(address(_callReceiver), data);
        assertEq(ret, abi.encode("0x1234"));
    }

    function testFunctionCallEmptyReturnWorks() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionEmptyReturn.selector);
        _harness.functionCall(address(_callReceiver), data);
    }

    function testFunctionCallRevertsNoReason() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionRevertsNoReason.selector);
        vm.expectRevert(bytes("Address: low-level call failed"));
        _harness.functionCall(address(_callReceiver), data);
    }

    function testFunctionCallBubblesReason() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionRevertsReason.selector);
        vm.expectRevert(bytes("CallReceiverMock: reverting"));
        _harness.functionCall(address(_callReceiver), data);
    }

    function testFunctionCallRevertsOutOfGas() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionOutOfGas.selector);
        vm.expectRevert(bytes("Address: low-level call failed"));
        _harness.functionCall{gas: 120000}(address(_callReceiver), data);
    }

    function testFunctionCallThrows() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionThrows.selector);
        vm.expectRevert();
        _harness.functionCall(address(_callReceiver), data);
    }

    function testFunctionCallUsesProvidedErrorMessage() public {
        vm.expectRevert(bytes("Address: expected error"));
        _harness.functionCallError(address(_callReceiver), hex"12345678", "Address: expected error");
    }

    function testFunctionCallRevertsWhenFunctionDoesNotExist() public {
        vm.expectRevert(bytes("Address: low-level call failed"));
        _harness.functionCall(address(_callReceiver), hex"01020304");
    }

    function testFunctionCallRevertsOnNonContract() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.expectRevert(bytes("Address: call to non-contract"));
        _harness.functionCall(_other, data);
    }

    function testFunctionCallWithValueZero() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        bytes memory ret = _harness.functionCallWithValue(address(_callReceiver), data, 0);
        assertEq(ret, abi.encode("0x1234"));
    }

    function testFunctionCallWithValueRevertsOnInsufficientBalance() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.expectRevert(bytes("Address: insufficient balance for call"));
        _harness.functionCallWithValue(address(_callReceiver), data, 1 ether);
    }

    function testFunctionCallWithValueUsesExistingBalance() public {
        uint256 amount = 12e17;
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.deal(address(_harness), amount);
        uint256 beforeBalance = address(_callReceiver).balance;

        bytes memory ret = _harness.functionCallWithValue(address(_callReceiver), data, amount);
        assertEq(ret, abi.encode("0x1234"));
        assertEq(address(_callReceiver).balance - beforeBalance, amount);
    }

    function testFunctionCallWithValueUsesTransactionFunds() public {
        uint256 amount = 12e17;
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.deal(_other, amount);
        uint256 beforeBalance = address(_callReceiver).balance;
        vm.prank(_other);
        bytes memory ret = _harness.functionCallWithValue{value: amount}(address(_callReceiver), data, amount);
        assertEq(ret, abi.encode("0x1234"));
        assertEq(address(_callReceiver).balance - beforeBalance, amount);
    }

    function testFunctionCallWithValueRevertsForNonPayableTarget() public {
        uint256 amount = 1 ether;
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionNonPayable.selector);
        vm.deal(address(_harness), amount);
        vm.expectRevert(bytes("Address: low-level call with value failed"));
        _harness.functionCallWithValue(address(_callReceiver), data, amount);
    }

    function testFunctionCallWithValueUsesProvidedErrorMessage() public {
        vm.expectRevert(bytes("Address: expected error"));
        _harness.functionCallWithValueError(address(_callReceiver), hex"12345678", 0, "Address: expected error");
    }

    function testFunctionStaticCallWorks() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockStaticFunction.selector);
        assertEq(_harness.functionStaticCall(address(_callReceiver), data), abi.encode("0x1234"));
    }

    function testFunctionStaticCallRevertsOnNonStaticFunction() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.expectRevert(bytes("Address: low-level static call failed"));
        _harness.functionStaticCall(address(_callReceiver), data);
    }

    function testFunctionStaticCallBubblesReason() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionRevertsReason.selector);
        vm.expectRevert(bytes("CallReceiverMock: reverting"));
        _harness.functionStaticCall(address(_callReceiver), data);
    }

    function testFunctionStaticCallRevertsOnNonContract() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.expectRevert(bytes("Address: call to non-contract"));
        _harness.functionStaticCall(_other, data);
    }

    function testFunctionStaticCallUsesProvidedErrorMessage() public {
        vm.expectRevert(bytes("Address: expected error"));
        _harness.functionStaticCallError(address(_callReceiver), hex"12345678", "Address: expected error");
    }

    function testFunctionDelegateCallWritesStorage() public {
        bytes32 slot = 0x93e4c53af435ddf777c3de84bb9a953a777788500e229a468ea1036496ab66a0;
        bytes32 value = 0x6a465d1c49869f71fb65562bcbd7e08c8044074927f0297127203f2a9924ff5b;
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionWritesStorage.selector, slot, value);

        assertEq(_harness.readSlot(slot), bytes32(0));
        bytes memory ret = _harness.functionDelegateCall(address(_callReceiver), data);
        assertEq(ret, abi.encode("0x1234"));
        assertEq(_harness.readSlot(slot), value);
    }

    function testFunctionDelegateCallBubblesReason() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunctionRevertsReason.selector);
        vm.expectRevert(bytes("CallReceiverMock: reverting"));
        _harness.functionDelegateCall(address(_callReceiver), data);
    }

    function testFunctionDelegateCallRevertsOnNonContract() public {
        bytes memory data = abi.encodeWithSelector(_callReceiver.mockFunction.selector);
        vm.expectRevert(bytes("Address: call to non-contract"));
        _harness.functionDelegateCall(_other, data);
    }

    function testFunctionDelegateCallUsesProvidedErrorMessage() public {
        vm.expectRevert(bytes("Address: expected error"));
        _harness.functionDelegateCallError(address(_callReceiver), hex"12345678", "Address: expected error");
    }

    function testVerifyCallResultReturnsDataOnSuccess() public {
        bytes memory returndata = hex"123abc";
        assertEq(_harness.verifyCallResult(true, returndata, ""), returndata);
    }

    function testVerifyCallResultRevertsWithErrorMessage() public {
        vm.expectRevert(bytes("Address: expected error"));
        _harness.verifyCallResult(false, bytes(""), "Address: expected error");
    }
}
