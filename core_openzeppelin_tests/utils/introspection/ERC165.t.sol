// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/introspection/ERC165.sol";
import "../../../src/utils/introspection/IERC165.sol";

contract ERC165Mock is ERC165 {}

contract ERC165Test is Test {
    function testSupportsInterface() public {
        ERC165Mock mock = new ERC165Mock();
        bytes4 ifaceId = type(IERC165).interfaceId;

        assertEq(ifaceId, bytes4(0x80ada41b));
        assertTrue(mock.supportsInterface(ifaceId));
        assertFalse(mock.supportsInterface(0xffffffff));
        assertFalse(mock.supportsInterface(0x12345678));
    }
}
