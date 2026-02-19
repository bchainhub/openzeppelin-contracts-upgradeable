// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^1.1.2;

import "./EDDSAUpgradeable.sol";
import "../../interfaces/IERC1271Upgradeable.sol";

/**
 * @dev Signature verification helper that can be used instead of `EDDSA.recover` to support both EDDSA
 * signatures from externally owned accounts (EOAs) and ERC1271 signatures from smart contract wallets.
 *
 * _Available since v4.1._
 */
library SignatureCheckerUpgradeable {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash.
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, EDDSAUpgradeable.RecoverError error) = EDDSAUpgradeable.tryRecover(hash, signature);
        return (error == EDDSAUpgradeable.RecoverError.NoError && recovered == signer)
            || isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash using ERC1271.
     */
    function isValidERC1271SignatureNow(address signer, bytes32 hash, bytes memory signature)
        internal
        view
        returns (bool)
    {
        (bool success, bytes memory result) =
            signer.staticcall(abi.encodeWithSelector(IERC1271Upgradeable.isValidSignature.selector, hash, signature));
        return (
            success && result.length >= 32
                && abi.decode(result, (bytes32)) == bytes32(IERC1271Upgradeable.isValidSignature.selector)
        );
    }
}
