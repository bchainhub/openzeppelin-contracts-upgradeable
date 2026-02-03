// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/cryptography/EIP712.sol";
import "../../../src/utils/cryptography/EDDSA.sol";
import "../../../src/proxy/Clones.sol";

contract EIP712Verifier is EIP712 {
    constructor(string memory name, string memory version) EIP712(name, version) {}

    function domainSeparatorV4() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function hashTypedDataV4(bytes32 structHash) external view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }

    function verify(bytes memory signature, address signer, address mailTo, string memory mailContents) external view {
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(keccak256("Mail(address to,string contents)"), mailTo, keccak256(bytes(mailContents))))
        );
        address recoveredSigner = EDDSA.recover(digest, signature);
        require(recoveredSigner == signer, "EIP712: invalid signature");
    }
}

contract EIP712Test is Test {
    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant MAIL_TYPEHASH = keccak256("Mail(address to,string contents)");

    string private constant SHORT_NAME = "A Name";
    string private constant SHORT_VERSION = "1";

    string private constant LONG_NAME = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    string private constant LONG_VERSION = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";

    function testDomainSeparatorShort() public {
        _testDomainSeparator(SHORT_NAME, SHORT_VERSION);
    }

    function testDomainSeparatorLong() public {
        _testDomainSeparator(LONG_NAME, LONG_VERSION);
    }

    function testDomainSeparatorCloneShort() public {
        EIP712Verifier implementation = new EIP712Verifier(SHORT_NAME, SHORT_VERSION);
        address clone = Clones.clone(address(implementation));
        EIP712Verifier proxy = EIP712Verifier(clone);

        bytes32 expected = _domainSeparator(SHORT_NAME, SHORT_VERSION, address(proxy));
        assertEq(proxy.domainSeparatorV4(), expected);
    }

    function testEip712DomainShort() public {
        _testEip712Domain(SHORT_NAME, SHORT_VERSION);
    }

    function testEip712DomainLong() public {
        _testEip712Domain(LONG_NAME, LONG_VERSION);
    }

    function testHashTypedDataV4Short() public {
        _testHashTypedDataV4(SHORT_NAME, SHORT_VERSION);
    }

    function testHashTypedDataV4Long() public {
        _testHashTypedDataV4(LONG_NAME, LONG_VERSION);
    }

    function testDigestShort() public {
        _testDigest(SHORT_NAME, SHORT_VERSION);
    }

    function testDigestLong() public {
        _testDigest(LONG_NAME, LONG_VERSION);
    }

    function _testDomainSeparator(string memory name, string memory version) private {
        EIP712Verifier eip712 = new EIP712Verifier(name, version);
        bytes32 expected = _domainSeparator(name, version, address(eip712));
        assertEq(eip712.domainSeparatorV4(), expected);
    }

    function _testEip712Domain(string memory name, string memory version) private {
        EIP712Verifier eip712 = new EIP712Verifier(name, version);
        (
            bytes1 fields,
            string memory reportedName,
            string memory reportedVersion,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        ) = eip712.eip712Domain();

        assertEq(fields, hex"0f");
        assertEq(reportedName, name);
        assertEq(reportedVersion, version);
        assertEq(chainId, block.chainid);
        assertEq(verifyingContract, address(eip712));
        assertEq(salt, bytes32(0));
        assertEq(extensions.length, 0);
    }

    function _testHashTypedDataV4(string memory name, string memory version) private {
        EIP712Verifier eip712 = new EIP712Verifier(name, version);
        bytes32 structHash = _mailStructHash(makeAddr("mailTo"), "very interesting");
        bytes32 expected = EDDSA.toTypedDataHash(_domainSeparator(name, version, address(eip712)), structHash);
        assertEq(eip712.hashTypedDataV4(structHash), expected);
    }

    function _testDigest(string memory name, string memory version) private {
        EIP712Verifier eip712 = new EIP712Verifier(name, version);
        (address signer, string memory key) = makeAddrAndKey("signer");
        address mailTo = makeAddr("mailTo");
        string memory contents = "very interesting";

        bytes32 digest = eip712.hashTypedDataV4(_mailStructHash(mailTo, contents));
        bytes memory sig = vm.sign(key, digest);

        eip712.verify(sig, signer, mailTo, contents);
    }

    function _domainSeparator(
        string memory name,
        string memory version,
        address verifyingContract
    ) private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes(version)), block.chainid, verifyingContract));
    }

    function _mailStructHash(address mailTo, string memory contents) private pure returns (bytes32) {
        return keccak256(abi.encode(MAIL_TYPEHASH, mailTo, keccak256(bytes(contents))));
    }
}
