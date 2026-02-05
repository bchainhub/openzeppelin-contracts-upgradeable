// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^1.1.2;

import "../ICRC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the CRC20 standard.
 */
interface ICRC20MetadataUpgradeable is ICRC20Upgradeable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
