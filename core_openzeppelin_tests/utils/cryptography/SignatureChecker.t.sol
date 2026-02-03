// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/cryptography/SignatureChecker.sol";
import "../../../src/utils/cryptography/EDDSA.sol";
import "../../../src/interfaces/IERC1271.sol";
import "../../../src/mocks/ERC1271WalletMock.sol";

contract SignatureCheckerHarness {
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) external view returns (bool) {
        return SignatureChecker.isValidSignatureNow(signer, hash, signature);
    }

    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) external view returns (bool) {
        return SignatureChecker.isValidERC1271SignatureNow(signer, hash, signature);
    }
}

contract SignatureCheckerTest is Test {
    SignatureCheckerHarness private _checker;
    ERC1271WalletMock private _wallet;
    ERC1271MaliciousMock private _malicious;

    address private _signer;
    address private _other;
    string private _signerKey;

    bytes32 private constant TEST_MESSAGE = keccak256("OpenZeppelin");
    bytes32 private constant WRONG_MESSAGE = keccak256("Nope");
    bytes4 private constant ERC1271_MAGICVALUE = 0x95f9a59b;

    function setUp() public {
        (_signer, _signerKey) = makeAddrAndKey("signer");
        _other = makeAddr("other");
        _checker = new SignatureCheckerHarness();
        _wallet = new ERC1271WalletMock(_signer);
        _malicious = new ERC1271MaliciousMock();
    }

    function testEOAValidSignature() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertTrue(_checker.isValidSignatureNow(_signer, digest, signature));
    }

    function testEOAInvalidSigner() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertFalse(_checker.isValidSignatureNow(_other, digest, signature));
    }

    function testEOAInvalidSignature() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes32 wrongDigest = _coreSigned(WRONG_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertFalse(_checker.isValidSignatureNow(_signer, wrongDigest, signature));
    }

    function testERC1271ValidSignature() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertEq(IERC1271.isValidSignature.selector, ERC1271_MAGICVALUE);
        assertEq(_wallet.isValidSignature(digest, signature), ERC1271_MAGICVALUE);
        assertTrue(_checker.isValidERC1271SignatureNow(address(_wallet), digest, signature));
        assertTrue(_checker.isValidSignatureNow(address(_wallet), digest, signature));
    }

    function testERC1271InvalidSigner() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertFalse(_checker.isValidERC1271SignatureNow(address(_checker), digest, signature));
        assertFalse(_checker.isValidSignatureNow(address(_checker), digest, signature));
    }

    function testERC1271InvalidSignature() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes32 wrongDigest = _coreSigned(WRONG_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertFalse(_checker.isValidERC1271SignatureNow(address(_wallet), wrongDigest, signature));
        assertFalse(_checker.isValidSignatureNow(address(_wallet), wrongDigest, signature));
    }

    function testERC1271MaliciousWallet() public {
        bytes32 digest = _coreSigned(TEST_MESSAGE);
        bytes memory signature = vm.sign(_signerKey, digest);

        assertFalse(_checker.isValidERC1271SignatureNow(address(_malicious), digest, signature));
        assertFalse(_checker.isValidSignatureNow(address(_malicious), digest, signature));
    }

    function _coreSigned(bytes32 message) private pure returns (bytes32) {
        return EDDSA.toCoreSignedMessageHash(message);
    }
}
