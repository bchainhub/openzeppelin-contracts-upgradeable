// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/metatx/ERC2771ContextUpgradeable.sol";
import "../../src/metatx/MinimalForwarderUpgradeable.sol";
import "../../src/utils/MulticallUpgradeable.sol";
import "../../src/utils/ContextUpgradeable.sol";
import "../../src/utils/cryptography/EDDSAUpgradeable.sol";

contract ERC2771ContextMockUpgradeable is ContextUpgradeable, ERC2771ContextUpgradeable, MulticallUpgradeable {
    event Sender(address sender);
    event Data(bytes data, uint256 integerValue, string stringValue);
    event DataShort(bytes data);

    constructor(address trustedForwarder) ERC2771ContextUpgradeable(trustedForwarder) {}

    function msgSender() public {
        emit Sender(_msgSender());
    }

    function msgData(uint256 integerValue, string memory stringValue) public {
        emit Data(_msgData(), integerValue, stringValue);
    }

    function msgDataShort() public {
        emit DataShort(_msgData());
    }

    function _msgSender() internal view override(ContextUpgradeable, ERC2771ContextUpgradeable) returns (address) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData()
        internal
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    function _contextSuffixLength()
        internal
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (uint256)
    {
        return ERC2771ContextUpgradeable._contextSuffixLength();
    }
}

contract ContextMockCallerUpgradeable {
    function callSender(ERC2771ContextMockUpgradeable context) public {
        context.msgSender();
    }

    function callData(ERC2771ContextMockUpgradeable context, uint256 integerValue, string memory stringValue) public {
        context.msgData(integerValue, stringValue);
    }
}

contract ERC2771ContextUpgradeableTest is Test {
    bytes32 private constant _DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant _FORWARD_TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    event Sender(address sender);
    event Data(bytes data, uint256 integerValue, string stringValue);
    event DataShort(bytes data);

    MinimalForwarderUpgradeable private _forwarder;
    ERC2771ContextMockUpgradeable private _recipient;

    function setUp() public {
        _forwarder = new MinimalForwarderUpgradeable();
        _forwarder.initialize();
        _recipient = new ERC2771ContextMockUpgradeable(address(_forwarder));
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
        ContextMockCallerUpgradeable caller = new ContextMockCallerUpgradeable();
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

        MinimalForwarderUpgradeable.ForwardRequest memory req = MinimalForwarderUpgradeable.ForwardRequest({
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

        MinimalForwarderUpgradeable.ForwardRequest memory req = MinimalForwarderUpgradeable.ForwardRequest({
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
        ERC2771ContextMockUpgradeable recipient = new ERC2771ContextMockUpgradeable(trustedForwarder);

        vm.prank(trustedForwarder);
        vm.expectEmit(true, false, false, true);
        emit Sender(trustedForwarder);
        recipient.msgSender();
    }

    function testMsgDataShortWithTrustedForwarder() public {
        address trustedForwarder = makeAddr("trustedForwarder");
        ERC2771ContextMockUpgradeable recipient = new ERC2771ContextMockUpgradeable(trustedForwarder);
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

        MinimalForwarderUpgradeable.ForwardRequest memory req = MinimalForwarderUpgradeable.ForwardRequest({
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
        return keccak256(
            abi.encode(
                _DOMAIN_TYPEHASH,
                keccak256(bytes("MinimalForwarder")),
                keccak256(bytes("0.0.1")),
                block.chainid,
                address(_forwarder)
            )
        );
    }

    function _digest(MinimalForwarderUpgradeable.ForwardRequest memory req) private view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(_FORWARD_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data))
        );
        return EDDSAUpgradeable.toTypedDataHash(_domainSeparator(), structHash);
    }
}
