// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.0;

import "spark-std/Test.sol";
import "../../src/utils/Address.sol";

contract AddressMock {
    using Address for address;
    using Address for address payable;

    function isContract(address account) external view returns (bool) {
        return Address.isContract(account);
    }

    function sendValue(address payable recipient, uint256 amount) external {
        Address.sendValue(recipient, amount);
    }

    function functionCall(address target, bytes memory data) external returns (bytes memory) {
        return Address.functionCall(target, data);
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external returns (bytes memory) {
        return Address.functionCall(target, data, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) external payable returns (bytes memory) {
        return Address.functionCallWithValue(target, data, value);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) external payable returns (bytes memory) {
        return Address.functionCallWithValue(target, data, value, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) external view returns (bytes memory) {
        return Address.functionStaticCall(target, data);
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external view returns (bytes memory) {
        return Address.functionStaticCall(target, data, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) external returns (bytes memory) {
        return Address.functionDelegateCall(target, data);
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external returns (bytes memory) {
        return Address.functionDelegateCall(target, data, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) external pure returns (bytes memory) {
        return Address.verifyCallResult(success, returndata, errorMessage);
    }

    receive() external payable {}
}

contract EtherReceiverMock {
    bool private _acceptEther;

    function setAcceptEther(bool acceptEther) public {
        _acceptEther = acceptEther;
    }

    receive() external payable {
        if (!_acceptEther) {
            revert();
        }
    }
}

contract CallReceiverMock {
    event MockFunctionCalled();
    event MockFunctionCalledWithArgs(uint256 a, uint256 b);

    uint256[] private _array;

    function mockFunction() public payable returns (string memory) {
        emit MockFunctionCalled();
        return "0x1234";
    }

    function mockFunctionEmptyReturn() public payable {
        emit MockFunctionCalled();
    }

    function mockFunctionWithArgs(uint256 a, uint256 b) public payable returns (string memory) {
        emit MockFunctionCalledWithArgs(a, b);
        return "0x1234";
    }

    function mockFunctionNonPayable() public returns (string memory) {
        emit MockFunctionCalled();
        return "0x1234";
    }

    function mockStaticFunction() public pure returns (string memory) {
        return "0x1234";
    }

    function mockFunctionRevertsNoReason() public payable {
        revert();
    }

    function mockFunctionRevertsReason() public payable {
        revert("CallReceiverMock: reverting");
    }

    function mockFunctionThrows() public payable {
        assert(false);
    }

    function mockFunctionOutOfGas() public payable {
        for (uint256 i = 0; ; ++i) {
            _array.push(i);
        }
    }

    function mockFunctionWritesStorage(bytes32 slot, bytes32 value) public returns (string memory) {
        assembly {
            sstore(slot, value)
        }
        return "0x1234";
    }
}

contract AddressTest is Test {
    AddressMock private _mock;
    address private _recipient;
    address private _other;

    function setUp() public {
        _mock = new AddressMock();
        _recipient = makeAddr("recipient");
        _other = makeAddr("other");
    }

    function testIsContractFalseForEOA() public {
        assertEq(_mock.isContract(_other), false);
    }

    function testIsContractTrueForContract() public {
        assertEq(_mock.isContract(address(_mock)), true);
    }

    function testSendValueNoFundsSendsZero() public {
        uint256 balanceBefore = _recipient.balance;
        _mock.sendValue(payable(_recipient), 0);
        assertEq(_recipient.balance, balanceBefore);
    }

    function testSendValueNoFundsRevertsNonZero() public {
        vm.expectRevert(bytes("Address: insufficient balance"));
        _mock.sendValue(payable(_recipient), 1);
    }

    function testSendValueWithFundsSendsZero() public {
        uint256 funds = 1 ether;
        vm.deal(address(_mock), funds);
        uint256 balanceBefore = _recipient.balance;
        _mock.sendValue(payable(_recipient), 0);
        assertEq(_recipient.balance, balanceBefore);
    }

    function testSendValueWithFundsSendsNonZero() public {
        uint256 funds = 1 ether;
        vm.deal(address(_mock), funds);
        uint256 balanceBefore = _recipient.balance;
        _mock.sendValue(payable(_recipient), funds - 1);
        assertEq(_recipient.balance, balanceBefore + (funds - 1));
    }

    function testSendValueWithFundsSendsWholeBalance() public {
        uint256 funds = 1 ether;
        vm.deal(address(_mock), funds);
        uint256 balanceBefore = _recipient.balance;
        _mock.sendValue(payable(_recipient), funds);
        assertEq(_recipient.balance, balanceBefore + funds);
        assertEq(address(_mock).balance, 0);
    }

    function testSendValueWithFundsRevertsIfOverBalance() public {
        uint256 funds = 1 ether;
        vm.deal(address(_mock), funds);
        vm.expectRevert(bytes("Address: insufficient balance"));
        _mock.sendValue(payable(_recipient), funds + 1);
    }

    function testSendValueToContractRecipient() public {
        uint256 funds = 1 ether;
        vm.deal(address(_mock), funds);
        EtherReceiverMock target = new EtherReceiverMock();
        target.setAcceptEther(true);
        uint256 balanceBefore = address(target).balance;
        _mock.sendValue(payable(address(target)), funds);
        assertEq(address(target).balance, balanceBefore + funds);
    }

    function testSendValueToContractRecipientRevertsOnReceive() public {
        uint256 funds = 1 ether;
        vm.deal(address(_mock), funds);
        EtherReceiverMock target = new EtherReceiverMock();
        target.setAcceptEther(false);
        vm.expectRevert(bytes("Address: unable to send value, recipient may have reverted"));
        _mock.sendValue(payable(address(target)), funds);
    }

    function testFunctionCallCallsRequestedFunction() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        bytes memory returndata = _mock.functionCall(address(target), data);
        assertEq(abi.decode(returndata, (string)), "0x1234");
    }

    function testFunctionCallEmptyReturn() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionEmptyReturn.selector);
        bytes memory returndata = _mock.functionCall(address(target), data);
        assertEq(returndata.length, 0);
    }

    function testFunctionCallRevertsNoReason() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionRevertsNoReason.selector);
        vm.expectRevert(bytes("Address: low-level call failed"));
        _mock.functionCall(address(target), data);
    }

    function testFunctionCallRevertsWithReason() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionRevertsReason.selector);
        vm.expectRevert(bytes("CallReceiverMock: reverting"));
        _mock.functionCall(address(target), data);
    }

    function testFunctionCallRevertsOutOfGas() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionOutOfGas.selector);
        vm.expectRevert(bytes("Address: low-level call failed"));
        _mock.functionCall{gas: 120000}(address(target), data);
    }

    function testFunctionCallRevertsOnAssert() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionThrows.selector);
        vm.expectRevert();
        _mock.functionCall(address(target), data);
    }

    function testFunctionCallBubblesCustomError() public {
        CallReceiverMock target = new CallReceiverMock();
        string memory errorMsg = "Address: expected error";
        vm.expectRevert(bytes(errorMsg));
        _mock.functionCall(address(target), hex"12345678", errorMsg);
    }

    function testFunctionCallRevertsWhenFunctionMissing() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSignature("mockFunctionDoesNotExist()");
        vm.expectRevert(bytes("Address: low-level call failed"));
        _mock.functionCall(address(target), data);
    }

    function testFunctionCallRevertsWhenTargetNotContract() public {
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        vm.expectRevert(bytes("Address: call to non-contract"));
        _mock.functionCall(_other, data);
    }

    function testFunctionCallWithValueZero() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        bytes memory returndata = _mock.functionCallWithValue(address(target), data, 0);
        assertEq(abi.decode(returndata, (string)), "0x1234");
    }

    function testFunctionCallWithValueRevertsIfInsufficientBalance() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        uint256 amount = 1_200_000_000_000_000_000;
        vm.expectRevert(bytes("Address: insufficient balance for call"));
        _mock.functionCallWithValue(address(target), data, amount);
    }

    function testFunctionCallWithValueWithExistingBalance() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        uint256 amount = 1_200_000_000_000_000_000;
        vm.deal(address(_mock), amount);
        uint256 balanceBefore = address(target).balance;
        bytes memory returndata = _mock.functionCallWithValue(address(target), data, amount);
        assertEq(abi.decode(returndata, (string)), "0x1234");
        assertEq(address(target).balance, balanceBefore + amount);
    }

    function testFunctionCallWithValueWithTransactionFunds() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        uint256 amount = 1_200_000_000_000_000_000;
        vm.deal(_other, amount);
        uint256 balanceBefore = address(target).balance;
        vm.prank(_other);
        bytes memory returndata = _mock.functionCallWithValue{value: amount}(address(target), data, amount);
        assertEq(abi.decode(returndata, (string)), "0x1234");
        assertEq(address(target).balance, balanceBefore + amount);
    }

    function testFunctionCallWithValueRevertsOnNonPayable() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionNonPayable.selector);
        uint256 amount = 1_200_000_000_000_000_000;
        vm.deal(address(_mock), amount);
        vm.expectRevert(bytes("Address: low-level call with value failed"));
        _mock.functionCallWithValue(address(target), data, amount);
    }

    function testFunctionCallWithValueBubblesCustomError() public {
        CallReceiverMock target = new CallReceiverMock();
        string memory errorMsg = "Address: expected error";
        vm.expectRevert(bytes(errorMsg));
        _mock.functionCallWithValue(address(target), hex"12345678", 0, errorMsg);
    }

    function testFunctionStaticCallCallsRequestedFunction() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockStaticFunction.selector);
        bytes memory returndata = _mock.functionStaticCall(address(target), data);
        assertEq(abi.decode(returndata, (string)), "0x1234");
    }

    function testFunctionStaticCallRevertsOnNonStatic() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        vm.expectRevert(bytes("Address: low-level static call failed"));
        _mock.functionStaticCall(address(target), data);
    }

    function testFunctionStaticCallBubblesRevertReason() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionRevertsReason.selector);
        vm.expectRevert(bytes("CallReceiverMock: reverting"));
        _mock.functionStaticCall(address(target), data);
    }

    function testFunctionStaticCallRevertsWhenTargetNotContract() public {
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        vm.expectRevert(bytes("Address: call to non-contract"));
        _mock.functionStaticCall(_other, data);
    }

    function testFunctionStaticCallBubblesCustomError() public {
        CallReceiverMock target = new CallReceiverMock();
        string memory errorMsg = "Address: expected error";
        vm.expectRevert(bytes(errorMsg));
        _mock.functionStaticCall(address(target), hex"12345678", errorMsg);
    }

    function testFunctionDelegateCallWritesStorage() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes32 slot = bytes32(uint256(0x93e4c53af435ddf777c3de84bb9a953a777788500e229a468ea1036496ab66a0));
        bytes32 value = bytes32(uint256(0x6a465d1c49869f71fb65562bcbd7e08c8044074927f0297127203f2a9924ff5b));
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionWritesStorage.selector, slot, value);
        assertEq(vm.load(address(_mock), slot), bytes32(0));
        bytes memory returndata = _mock.functionDelegateCall(address(target), data);
        assertEq(abi.decode(returndata, (string)), "0x1234");
        assertEq(vm.load(address(_mock), slot), value);
    }

    function testFunctionDelegateCallBubblesRevertReason() public {
        CallReceiverMock target = new CallReceiverMock();
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunctionRevertsReason.selector);
        vm.expectRevert(bytes("CallReceiverMock: reverting"));
        _mock.functionDelegateCall(address(target), data);
    }

    function testFunctionDelegateCallRevertsWhenTargetNotContract() public {
        bytes memory data = abi.encodeWithSelector(CallReceiverMock.mockFunction.selector);
        vm.expectRevert(bytes("Address: call to non-contract"));
        _mock.functionDelegateCall(_other, data);
    }

    function testFunctionDelegateCallBubblesCustomError() public {
        CallReceiverMock target = new CallReceiverMock();
        string memory errorMsg = "Address: expected error";
        vm.expectRevert(bytes(errorMsg));
        _mock.functionDelegateCall(address(target), hex"12345678", errorMsg);
    }

    function testVerifyCallResultReturnsReturndata() public {
        bytes memory returndata = hex"123abc";
        assertEq(_mock.verifyCallResult(true, returndata, ""), returndata);
    }

    function testVerifyCallResultRevertsWithErrorMessage() public {
        string memory errorMsg = "Address: expected error";
        vm.expectRevert(bytes(errorMsg));
        _mock.verifyCallResult(false, hex"", errorMsg);
    }
}
