// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^1.1.2;

/**
 * @dev Interface for contracts that want to support safeTransfers from CRC721 asset contracts.
 */
interface ICRC721Receiver {
    /**
     * @dev Whenever an {ICRC721} `tokenId` token is transferred to this contract via {ICRC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
