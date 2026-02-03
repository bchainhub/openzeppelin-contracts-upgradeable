// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^1.1.2;

import "../ICRC721.sol";

/**
 * @title CRC-721 Non-Fungible Token Standard, optional enumeration extension
 */
interface ICRC721Enumerable is ICRC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
