// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/introspection/ERC165Upgradeable.sol";
import "../../../src/utils/introspection/IERC165Upgradeable.sol";

contract ERC165UpgradeableMock is ERC165Upgradeable {}

contract ERC165UpgradeableTest is Test {
    function testSupportsInterface() public {
        ERC165UpgradeableMock mock = new ERC165UpgradeableMock();
        bytes4 ifaceId = type(IERC165Upgradeable).interfaceId;

        assertEq(ifaceId, bytes4(0x80ada41b));
        assertTrue(mock.supportsInterface(ifaceId));
        assertFalse(mock.supportsInterface(0xffffffff));
        assertFalse(mock.supportsInterface(0x12345678));
    }
}
