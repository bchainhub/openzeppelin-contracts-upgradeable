// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^1.1.2;

import "../ICRC721.sol";

/**
 * @title CRC721 Non-Fungible Token Standard, optional metadata extension
 */
interface ICRC721Metadata is ICRC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
