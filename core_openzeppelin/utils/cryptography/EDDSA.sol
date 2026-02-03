// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EDDSA.sol)

pragma solidity 1.1.2;

import "../Strings.sol";

/**
 * @dev Edwards-curve Digital Signature Algorithm (EDDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library EDDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("EDDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("EDDSA: invalid signature length");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toCoreSignedMessageHash} on it.
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal view returns (address, RecoverError) {
        if (signature.length != 171) {
            return (address(0), RecoverError.InvalidSignatureLength);
        }

        // address signer = ecrecover(hash, signature);
        address signer;
        bool ok;
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, hash)
            mstore(add(ptr, 0x20), 0x40)
            mstore(add(ptr, 0x40), 171)

            let src := add(signature, 0x20)
            let dst := add(ptr, 0x60)

            mstore(dst, mload(src))
            mstore(add(dst, 0x20), mload(add(src, 0x20)))
            mstore(add(dst, 0x40), mload(add(src, 0x40)))
            mstore(add(dst, 0x60), mload(add(src, 0x60)))
            mstore(add(dst, 0x80), mload(add(src, 0x80)))
            mstore(add(dst, 0xA0), mload(add(src, 0xA0)))

            let success := staticcall(5000, 0x01, ptr, 0x120, ptr, 0x20)

            if success {
                let word := mload(ptr)
                let mask := sub(shl(176, 1), 1)
                signer := and(word, mask)

                if signer { ok := 1 }
            }

            mstore(0x40, add(ptr, 0x140))
        }
        if (!ok) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     */
    function recover(bytes32 hash, bytes memory signature) internal view returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns a Core Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * `core_sign` JSON-RPC method as part of EIP-191 style signing.
     */
    function toCoreSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        assembly {
            mstore(0x00, "\x19Core Signed Message:\n32")
            mstore(0x18, hash)
            message := keccak256(0x00, 0x38)
        }
    }

    /**
     * @dev Returns a Core Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * `core_sign` JSON-RPC method as part of EIP-191 style signing.
     */
    function toCoreSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Core Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns a Core Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the `core_signTypedData` JSON-RPC method.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns a Core Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
