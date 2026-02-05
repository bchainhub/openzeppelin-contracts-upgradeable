// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^1.1.2;

import "../ICRC721Upgradeable.sol";

/**
 * @title CRC721 Non-Fungible Token Standard, optional metadata extension
 */
interface ICRC721MetadataUpgradeable is ICRC721Upgradeable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
