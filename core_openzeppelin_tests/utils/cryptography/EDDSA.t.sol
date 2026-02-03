// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/cryptography/EDDSA.sol";
import "../../../src/utils/Strings.sol";

contract EDDSAHarness {
    function recover(bytes32 hash, bytes memory signature) external view returns (address) {
        return EDDSA.recover(hash, signature);
    }

    function toCoreSignedMessageHash(bytes32 hash) external pure returns (bytes32) {
        return EDDSA.toCoreSignedMessageHash(hash);
    }

    function toCoreSignedMessageHashBytes(bytes memory data) external pure returns (bytes32) {
        return EDDSA.toCoreSignedMessageHash(data);
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) external pure returns (bytes32) {
        return EDDSA.toTypedDataHash(domainSeparator, structHash);
    }

    function toDataWithIntendedValidatorHash(address validator, bytes memory data) external pure returns (bytes32) {
        return EDDSA.toDataWithIntendedValidatorHash(validator, data);
    }
}

contract EDDSATest is Test {
    EDDSAHarness private _eddsa;

    bytes32 private constant TEST_MESSAGE = keccak256("OpenZeppelin");
    bytes32 private constant WRONG_MESSAGE = keccak256("Nope");

    function setUp() public {
        _eddsa = new EDDSAHarness();
    }

    function testRecoverWithShortSignature() public {
        bytes memory sig = hex"1234";
        vm.expectRevert(bytes("EDDSA: invalid signature length"));
        _eddsa.recover(TEST_MESSAGE, sig);
    }

    function testRecoverWithLongSignature() public {
        bytes memory sig = new bytes(172);
        vm.expectRevert(bytes("EDDSA: invalid signature length"));
        _eddsa.recover(TEST_MESSAGE, sig);
    }

    function testRecoverWithValidSignature() public {
        (address signer, string memory key) = makeAddrAndKey("signer");
        bytes32 digest = _eddsa.toCoreSignedMessageHash(TEST_MESSAGE);
        bytes memory sig = vm.sign(key, digest);

        assertEq(sig.length, 171);
        assertEq(_eddsa.recover(digest, sig), signer);
    }

    function testRecoverWithDifferentMessage() public {
        (, string memory key) = makeAddrAndKey("signer");
        bytes32 digest = _eddsa.toCoreSignedMessageHash(TEST_MESSAGE);
        bytes memory sig = vm.sign(key, digest);

        bytes32 wrongDigest = _eddsa.toCoreSignedMessageHash(WRONG_MESSAGE);
        vm.expectRevert();
        _eddsa.recover(wrongDigest, sig);
    }

    function testRecoverWithInvalidSignature() public {
        bytes memory sig = new bytes(171);
        vm.expectRevert();
        _eddsa.recover(TEST_MESSAGE, sig);
    }

    function testToCoreSignedMessageHashBytes32() public {
        bytes32 expected = keccak256(abi.encodePacked("\x19Core Signed Message:\n32", TEST_MESSAGE));
        assertEq(_eddsa.toCoreSignedMessageHash(TEST_MESSAGE), expected);
    }

    function testToCoreSignedMessageHashBytes() public {
        bytes memory data = "abcd";
        bytes32 expected = keccak256(
            abi.encodePacked("\x19Core Signed Message:\n", Strings.toString(data.length), data)
        );
        assertEq(_eddsa.toCoreSignedMessageHashBytes(data), expected);
    }

    function testToTypedDataHash() public {
        bytes32 domainSeparator = keccak256("domain");
        bytes32 structHash = keccak256("struct");
        bytes32 expected = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        assertEq(_eddsa.toTypedDataHash(domainSeparator, structHash), expected);
    }

    function testToDataWithIntendedValidatorHash() public {
        address validator = makeAddr("validator");
        bytes memory data = hex"1234";
        bytes32 expected = keccak256(abi.encodePacked("\x19\x00", validator, data));
        assertEq(_eddsa.toDataWithIntendedValidatorHash(validator, data), expected);
    }
}
