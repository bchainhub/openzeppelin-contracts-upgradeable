// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/access/AccessControl.sol";
import "../../src/utils/Strings.sol";

contract AccessControlMock is AccessControl {
    function checkRole(bytes32 role, address account) external view {
        _checkRole(role, account);
    }

    function checkRole(bytes32 role) external view {
        _checkRole(role);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external {
        _setRoleAdmin(role, adminRole);
    }

    function grantRoleInternal(bytes32 role, address account) external {
        _grantRole(role, account);
    }

    function revokeRoleInternal(bytes32 role, address account) external {
        _revokeRole(role, account);
    }
}

contract AccessControlTest is Test {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    AccessControlMock private _access;

    address private _admin;
    address private _authorized;
    address private _other;
    address private _otherAdmin;

    bytes32 private constant ROLE = keccak256("ROLE");
    bytes32 private constant OTHER_ROLE = keccak256("OTHER_ROLE");

    function setUp() public {
        _admin = address(0x1111);
        _authorized = address(0x2222);
        _other = address(0x3333);
        _otherAdmin = address(0x4444);

        _access = new AccessControlMock();
        _access.grantRoleInternal(_access.DEFAULT_ADMIN_ROLE(), _admin);
    }

    function testSupportsInterface() public {
        bytes4 ifaceId = _interfaceIdAccessControl();
        assertTrue(_access.supportsInterface(ifaceId));
        assertTrue(_access.supportsInterface(bytes4(0x80ada41b)));
        assertFalse(_access.supportsInterface(0xffffffff));
    }

    function testDefaultAdminRole() public {
        assertTrue(_access.hasRole(_access.DEFAULT_ADMIN_ROLE(), _admin));
        assertEq(_access.getRoleAdmin(ROLE), _access.DEFAULT_ADMIN_ROLE());
        assertEq(_access.getRoleAdmin(_access.DEFAULT_ADMIN_ROLE()), _access.DEFAULT_ADMIN_ROLE());
    }

    function testGrantingRoleByAdmin() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);
        assertTrue(_access.hasRole(ROLE, _authorized));
    }

    function testGrantingRoleByNonAdminReverts() public {
        string memory expected = _missingRole(_other, _access.DEFAULT_ADMIN_ROLE());
        vm.prank(_other);
        vm.expectRevert(bytes(expected));
        _access.grantRole(ROLE, _authorized);
    }

    function testGrantingSameRoleDoesNotEmit() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        assertTrue(_access.hasRole(ROLE, _authorized));
    }

    function testRevokeRoleByAdmin() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        vm.prank(_admin);
        vm.expectEmit(true, true, true, true);
        emit RoleRevoked(ROLE, _authorized, _admin);
        _access.revokeRole(ROLE, _authorized);

        assertFalse(_access.hasRole(ROLE, _authorized));
    }

    function testRevokeRoleByNonAdminReverts() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        string memory expected = _missingRole(_other, _access.DEFAULT_ADMIN_ROLE());
        vm.prank(_other);
        vm.expectRevert(bytes(expected));
        _access.revokeRole(ROLE, _authorized);
    }

    function testRenounceRole() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        vm.prank(_authorized);
        vm.expectEmit(true, true, true, true);
        emit RoleRevoked(ROLE, _authorized, _authorized);
        _access.renounceRole(ROLE, _authorized);

        assertFalse(_access.hasRole(ROLE, _authorized));
    }

    function testRenounceRoleByOtherReverts() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        vm.prank(_admin);
        vm.expectRevert(bytes("AccessControl: can only renounce roles for self"));
        _access.renounceRole(ROLE, _authorized);
    }

    function testSetRoleAdmin() public {
        vm.expectEmit(true, true, true, true);
        emit RoleAdminChanged(ROLE, _access.DEFAULT_ADMIN_ROLE(), OTHER_ROLE);
        _access.setRoleAdmin(ROLE, OTHER_ROLE);

        vm.prank(_admin);
        _access.grantRole(OTHER_ROLE, _otherAdmin);

        vm.prank(_otherAdmin);
        vm.expectEmit(true, true, true, true);
        emit RoleGranted(ROLE, _authorized, _otherAdmin);
        _access.grantRole(ROLE, _authorized);

        string memory expected = _missingRole(_admin, OTHER_ROLE);
        vm.prank(_admin);
        vm.expectRevert(bytes(expected));
        _access.grantRole(ROLE, _other);
    }

    function testOnlyRoleCheck() public {
        vm.prank(_admin);
        _access.grantRole(ROLE, _authorized);

        vm.prank(_authorized);
        _access.checkRole(ROLE);

        string memory expected = _missingRole(_other, ROLE);
        vm.prank(_other);
        vm.expectRevert(bytes(expected));
        _access.checkRole(ROLE);
    }

    function _interfaceIdAccessControl() private pure returns (bytes4) {
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = _selector("hasRole(bytes32,address)");
        selectors[1] = _selector("getRoleAdmin(bytes32)");
        selectors[2] = _selector("grantRole(bytes32,address)");
        selectors[3] = _selector("revokeRole(bytes32,address)");
        selectors[4] = _selector("renounceRole(bytes32,address)");
        return _xorSelectors(selectors);
    }

    function _selector(string memory sig) private pure returns (bytes4) {
        return bytes4(keccak256(bytes(sig)));
    }

    function _xorSelectors(bytes4[] memory selectors) private pure returns (bytes4 id) {
        for (uint256 i = 0; i < selectors.length; i++) {
            id ^= selectors[i];
        }
    }

    function _missingRole(address account, bytes32 role) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "AccessControl: account ",
                    Strings.toHexString(account),
                    " is missing role ",
                    Strings.toHexString(uint256(role), 32)
                )
            );
    }
}
