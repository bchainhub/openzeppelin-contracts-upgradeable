// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/Base64.sol";

contract Base64Harness {
    function encode(bytes memory input) external pure returns (string memory) {
        return Base64.encode(input);
    }
}

contract Base64Dirty {
    struct A {
        uint256 value;
    }

    function encode(bytes memory input) public pure returns (string memory) {
        A memory unused = A({value: type(uint256).max});
        // Silence warning about unused local variable.
        unused;

        return Base64.encode(input);
    }
}

contract Base64Test is Test {
    Base64Harness private _base64;

    function setUp() public {
        _base64 = new Base64Harness();
    }

    function testEncodeDoublePadding() public {
        bytes memory input = bytes("test");
        assertEq(_base64.encode(input), "dGVzdA==");
    }

    function testEncodeSinglePadding() public {
        bytes memory input = bytes("test1");
        assertEq(_base64.encode(input), "dGVzdDE=");
    }

    function testEncodeNoPadding() public {
        bytes memory input = bytes("test12");
        assertEq(_base64.encode(input), "dGVzdDEy");
    }

    function testEncodeEmptyBytes() public {
        bytes memory input = new bytes(0);
        assertEq(_base64.encode(input), "");
    }

    function testEncodeDirtyMemory() public {
        Base64Dirty mock = new Base64Dirty();
        bytes32 hash = keccak256(abi.encodePacked("example"));
        bytes memory buffer32 = abi.encodePacked(hash);
        bytes memory buffer30 = new bytes(30);

        for (uint256 i = 0; i < buffer30.length; ++i) {
            buffer30[i] = buffer32[i];
        }

        assertEq(mock.encode(buffer30), "cJg9aS9kgYX+vm1vpgdjCuaGSffm/EW5RoAJbAbk");
        assertEq(mock.encode(buffer32), "cJg9aS9kgYX+vm1vpgdjCuaGSffm/EW5RoAJbAbk+ts=");
    }
}
