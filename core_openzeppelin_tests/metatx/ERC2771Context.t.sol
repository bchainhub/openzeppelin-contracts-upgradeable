// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/metatx/ERC2771Context.sol";
import "../../src/metatx/MinimalForwarder.sol";
import "../../src/utils/Multicall.sol";
import "../../src/utils/Context.sol";
import "../../src/utils/cryptography/EDDSA.sol";

contract ERC2771ContextMock is Context, ERC2771Context, Multicall {
    event Sender(address sender);
    event Data(bytes data, uint256 integerValue, string stringValue);
    event DataShort(bytes data);

    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {}

    function msgSender() public {
        emit Sender(_msgSender());
    }

    function msgData(uint256 integerValue, string memory stringValue) public {
        emit Data(_msgData(), integerValue, stringValue);
    }

    function msgDataShort() public {
        emit DataShort(_msgData());
    }

    function _msgSender() internal view override(Context, ERC2771Context) returns (address) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    function _contextSuffixLength() internal view override(Context, ERC2771Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}

contract ContextMockCaller {
    function callSender(ERC2771ContextMock context) public {
        context.msgSender();
    }

    function callData(ERC2771ContextMock context, uint256 integerValue, string memory stringValue) public {
        context.msgData(integerValue, stringValue);
    }
}

contract ERC2771ContextTest is Test {
    bytes32 private constant _DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant _FORWARD_TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    event Sender(address sender);
    event Data(bytes data, uint256 integerValue, string stringValue);
    event DataShort(bytes data);

    MinimalForwarder private _forwarder;
    ERC2771ContextMock private _recipient;

    function setUp() public {
        _forwarder = new MinimalForwarder();
        _recipient = new ERC2771ContextMock(address(_forwarder));
    }

    function testRecognizeTrustedForwarder() public {
        assertTrue(_recipient.isTrustedForwarder(address(_forwarder)));
    }

    function testRegularContextMsgSenderFromEOA() public {
        vm.expectEmit(true, false, false, true);
        emit Sender(address(this));
        _recipient.msgSender();
    }

    function testRegularContextMsgSenderFromContract() public {
        ContextMockCaller caller = new ContextMockCaller();
        vm.expectEmit(true, false, false, true);
        emit Sender(address(caller));
        caller.callSender(_recipient);
    }

    function testRegularContextMsgDataFromEOA() public {
        uint256 integerValue = 42;
        string memory stringValue = "OpenZeppelin";
        bytes memory callData = abi.encodeWithSelector(_recipient.msgData.selector, integerValue, stringValue);

        vm.expectEmit(false, false, false, true);
        emit Data(callData, integerValue, stringValue);
        _recipient.msgData(integerValue, stringValue);
    }

    function testRelayedMsgSender() public {
        (address from, string memory key) = makeAddrAndKey("sender");

        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: from,
            to: address(_recipient),
            value: 0,
            gas: 200_000,
            nonce: _forwarder.getNonce(from),
            data: abi.encodeWithSelector(_recipient.msgSender.selector)
        });

        bytes memory signature = vm.sign(key, _digest(req));
        assertTrue(_forwarder.verify(req, signature));

        vm.expectEmit(true, false, false, true);
        emit Sender(from);
        _forwarder.execute(req, signature);
    }

    function testRelayedMsgData() public {
        (address from, string memory key) = makeAddrAndKey("sender");
        uint256 integerValue = 42;
        string memory stringValue = "OpenZeppelin";
        bytes memory data = abi.encodeWithSelector(_recipient.msgData.selector, integerValue, stringValue);

        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: from,
            to: address(_recipient),
            value: 0,
            gas: 250_000,
            nonce: _forwarder.getNonce(from),
            data: data
        });

        bytes memory signature = vm.sign(key, _digest(req));
        assertTrue(_forwarder.verify(req, signature));

        vm.expectEmit(false, false, false, true);
        emit Data(data, integerValue, stringValue);
        _forwarder.execute(req, signature);
    }

    function testMsgSenderShortDataWithTrustedForwarder() public {
        address trustedForwarder = makeAddr("trustedForwarder");
        ERC2771ContextMock recipient = new ERC2771ContextMock(trustedForwarder);

        vm.prank(trustedForwarder);
        vm.expectEmit(true, false, false, true);
        emit Sender(trustedForwarder);
        recipient.msgSender();
    }

    function testMsgDataShortWithTrustedForwarder() public {
        address trustedForwarder = makeAddr("trustedForwarder");
        ERC2771ContextMock recipient = new ERC2771ContextMock(trustedForwarder);
        bytes memory data = abi.encodeWithSelector(recipient.msgDataShort.selector);

        vm.prank(trustedForwarder);
        vm.expectEmit(false, false, false, true);
        emit DataShort(data);
        recipient.msgDataShort();
    }

    function testMulticallPoisonAttack() public {
        (address attacker, string memory key) = makeAddrAndKey("attacker");
        address other = makeAddr("other");

        bytes memory msgSenderCall = abi.encodeWithSelector(_recipient.msgSender.selector);
        bytes[] memory calls = new bytes[](1);
        calls[0] = bytes.concat(msgSenderCall, abi.encodePacked(other));

        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: attacker,
            to: address(_recipient),
            value: 0,
            gas: 300_000,
            nonce: _forwarder.getNonce(attacker),
            data: abi.encodeWithSelector(_recipient.multicall.selector, calls)
        });

        bytes memory signature = vm.sign(key, _digest(req));
        assertTrue(_forwarder.verify(req, signature));

        vm.expectEmit(true, false, false, true);
        emit Sender(attacker);
        _forwarder.execute(req, signature);
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
