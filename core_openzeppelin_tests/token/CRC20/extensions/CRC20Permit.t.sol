// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20Permit.sol";
import "../../../../src/utils/cryptography/EDDSA.sol";

contract CRC20PermitMock is CRC20Permit {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) CRC20Permit(name_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CRC20PermitTest is Test {
    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    string private constant _NAME = "My Token";
    string private constant _SYMBOL = "MTKN";
    string private constant _VERSION = "1";

    CRC20PermitMock private _token;

    address private _owner;
    address private _spender;
    string private _ownerKey;

    function setUp() public {
        (_owner, _ownerKey) = makeAddrAndKey("owner");
        _spender = makeAddr("spender");
        _token = new CRC20PermitMock(_NAME, _SYMBOL);
        _token.mint(_owner, 100);
    }

    function testInitialNonceIsZero() public {
        assertEq(_token.nonces(_owner), 0);
    }

    function testDomainSeparator() public {
        bytes32 expected = _domainSeparator(address(_token));
        assertEq(_token.DOMAIN_SEPARATOR(), expected);
    }

    function testPermitAcceptsOwnerSignature() public {
        uint256 value = 42;
        uint256 nonce = _token.nonces(_owner);
        uint256 deadline = type(uint256).max;
        bytes32 digest = _permitDigest(_owner, _spender, value, nonce, deadline);
        bytes memory sig = vm.sign(_ownerKey, digest);

        _token.permit(_owner, _spender, value, deadline, sig);

        assertEq(_token.nonces(_owner), nonce + 1);
        assertEq(_token.allowance(_owner, _spender), value);
    }

    function testRevertsOnReusedSignature() public {
        uint256 value = 42;
        uint256 nonce = _token.nonces(_owner);
        uint256 deadline = type(uint256).max;
        bytes32 digest = _permitDigest(_owner, _spender, value, nonce, deadline);
        bytes memory sig = vm.sign(_ownerKey, digest);

        _token.permit(_owner, _spender, value, deadline, sig);

        vm.expectRevert(bytes("CRC20Permit: invalid signature"));
        _token.permit(_owner, _spender, value, deadline, sig);
    }

    function testRevertsOnOtherSignature() public {
        uint256 value = 42;
        uint256 nonce = _token.nonces(_owner);
        uint256 deadline = type(uint256).max;
        bytes32 digest = _permitDigest(_owner, _spender, value, nonce, deadline);
        (, string memory otherKey) = makeAddrAndKey("otherOwner");
        bytes memory sig = vm.sign(otherKey, digest);

        vm.expectRevert(bytes("CRC20Permit: invalid signature"));
        _token.permit(_owner, _spender, value, deadline, sig);
    }

    function testRevertsOnExpiredPermit() public {
        vm.warp(100);
        uint256 value = 42;
        uint256 nonce = _token.nonces(_owner);
        uint256 deadline = 99;
        bytes32 digest = _permitDigest(_owner, _spender, value, nonce, deadline);
        bytes memory sig = vm.sign(_ownerKey, digest);

        vm.expectRevert(bytes("CRC20Permit: expired deadline"));
        _token.permit(_owner, _spender, value, deadline, sig);
    }

    function _domainSeparator(address verifyingContract) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes(_NAME)),
                    keccak256(bytes(_VERSION)),
                    block.chainid,
                    verifyingContract
                )
            );
    }

    function _permitDigest(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) private view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        return EDDSA.toTypedDataHash(_domainSeparator(address(_token)), structHash);
    }
}
