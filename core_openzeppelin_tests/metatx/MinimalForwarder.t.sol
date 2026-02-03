// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/metatx/MinimalForwarder.sol";
import "../../src/utils/cryptography/EDDSA.sol";

contract CallReceiverMock {
    uint256 public x;

    function setX(uint256 value) external {
        x = value;
    }

    function mockFunctionOutOfGas() external pure {
        uint256 n = 0;
        while (true) {
            n++;
        }
    }
}

contract MinimalForwarderTest is Test {
    bytes32 private constant _DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant _FORWARD_TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    MinimalForwarder private _forwarder;
    address private _from;
    string private _fromKey;

    function setUp() public {
        _forwarder = new MinimalForwarder();
        (_from, _fromKey) = makeAddrAndKey("from");
    }

    function testVerifyValidSignature() public {
        MinimalForwarder.ForwardRequest memory req = _defaultRequest(_from, address(0), hex"");
        bytes memory signature = vm.sign(_fromKey, _digest(req));

        assertTrue(_forwarder.verify(req, signature));
    }

    function testVerifyTamperedFields() public {
        MinimalForwarder.ForwardRequest memory req = _defaultRequest(_from, address(0), hex"");
        bytes memory signature = vm.sign(_fromKey, _digest(req));

        MinimalForwarder.ForwardRequest memory tampered = req;
        tampered.to = makeAddr("to");
        assertFalse(_forwarder.verify(tampered, signature));

        tampered = req;
        tampered.value = 1;
        assertFalse(_forwarder.verify(tampered, signature));

        tampered = req;
        tampered.nonce = req.nonce + 1;
        assertFalse(_forwarder.verify(tampered, signature));

        tampered = req;
        tampered.data = hex"1742";
        assertFalse(_forwarder.verify(tampered, signature));
    }

    function testVerifyTamperedSignature() public {
        MinimalForwarder.ForwardRequest memory req = _defaultRequest(_from, address(0), hex"");
        bytes memory signature = vm.sign(_fromKey, _digest(req));
        signature[42] = bytes1(uint8(signature[42]) ^ 0xff);

        assertFalse(_forwarder.verify(req, signature));
    }

    function testExecuteValidSignatureIncrementsNonce() public {
        MinimalForwarder.ForwardRequest memory req = _defaultRequest(_from, address(0), hex"");
        bytes memory signature = vm.sign(_fromKey, _digest(req));

        (bool success, ) = _forwarder.execute(req, signature);
        assertTrue(success);
        assertEq(_forwarder.getNonce(_from), req.nonce + 1);
    }

    function testExecuteInvalidSignatureReverts() public {
        MinimalForwarder.ForwardRequest memory req = _defaultRequest(_from, address(0), hex"");
        bytes memory signature = vm.sign(_fromKey, _digest(req));
        req.to = makeAddr("tampered");

        vm.expectRevert(bytes("MinimalForwarder: signature does not match request"));
        _forwarder.execute(req, signature);
    }

    function testExecuteBubbleOutOfGas() public {
        CallReceiverMock receiver = new CallReceiverMock();
        MinimalForwarder.ForwardRequest memory req = _defaultRequest(
            _from,
            address(receiver),
            abi.encodeWithSelector(receiver.mockFunctionOutOfGas.selector)
        );
        req.gas = 1_000_000;
        bytes memory signature = vm.sign(_fromKey, _digest(req));

        vm.expectRevert();
        _forwarder.execute{gas: 100_000}(req, signature);
    }

    function _defaultRequest(
        address from,
        address to,
        bytes memory data
    ) private view returns (MinimalForwarder.ForwardRequest memory req) {
        req = MinimalForwarder.ForwardRequest({
            from: from,
            to: to,
            value: 0,
            gas: 100_000,
            nonce: _forwarder.getNonce(from),
            data: data
        });
    }

    function _domainSeparator() private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _DOMAIN_TYPEHASH,
                    keccak256(bytes("MinimalForwarder")),
                    keccak256(bytes("0.0.1")),
                    block.chainid,
                    address(_forwarder)
                )
            );
    }

    function _digest(MinimalForwarder.ForwardRequest memory req) private view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(_FORWARD_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data))
        );
        return EDDSA.toTypedDataHash(_domainSeparator(), structHash);
    }
}
