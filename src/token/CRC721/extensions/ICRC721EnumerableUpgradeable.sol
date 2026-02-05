// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^1.1.2;

import "../ICRC721Upgradeable.sol";

/**
 * @title CRC721 Non-Fungible Token Standard, optional enumeration extension
 */
interface ICRC721EnumerableUpgradeable is ICRC721Upgradeable {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);
}
