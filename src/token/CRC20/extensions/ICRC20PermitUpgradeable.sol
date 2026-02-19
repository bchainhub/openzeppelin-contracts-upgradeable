// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^1.1.2;

/**
 * @dev Interface of the CRC20 Permit extension allowing approvals to be made via signatures.
 */
interface ICRC20PermitUpgradeable {
    function permit(address owner, address spender, uint256 value, uint256 deadline, bytes memory signature) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
