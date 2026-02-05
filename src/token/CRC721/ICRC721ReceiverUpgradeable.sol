// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^1.1.2;

/**
 * @dev Interface for contracts that want to support safeTransfers from CRC721 asset contracts.
 */
interface ICRC721ReceiverUpgradeable {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
