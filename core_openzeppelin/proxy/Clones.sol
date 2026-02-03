// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^1.1.2;

import "../utils/Create2.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        bytes memory code = _cloneBytecode(implementation);
        /// @solidity memory-safe-assembly
        assembly {
            instance := create(0, add(code, 0x20), mload(code))
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        bytes memory code = _cloneBytecode(implementation);
        /// @solidity memory-safe-assembly
        assembly {
            instance := create2(0, add(code, 0x20), mload(code), salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal view returns (address predicted) {
        bytes32 codeHash = keccak256(_cloneBytecode(implementation));
        return Create2.computeAddress(salt, codeHash, deployer);
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }

    function _cloneBytecode(address implementation) private pure returns (bytes memory) {
        return abi.encodePacked(
            hex"3d602f80600a3d3981f3",
            hex"363d3d373d3d3d363d75",
            bytes22(uint176(implementation)),
            hex"5af43d82803e903d91602d57fd5bf3"
        );
    }
}
