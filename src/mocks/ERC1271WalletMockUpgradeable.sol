// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../interfaces/IERC1271Upgradeable.sol";
import "../utils/cryptography/EDDSAUpgradeable.sol";

contract ERC1271WalletMockUpgradeable is IERC1271Upgradeable {
    address private _owner;

    constructor(address originalOwner) {
        _owner = originalOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isValidSignature(bytes32 hash, bytes memory signature) public view override returns (bytes4 magicValue) {
        return EDDSAUpgradeable.recover(hash, signature) == owner() ? this.isValidSignature.selector : bytes4(0);
    }
}

contract ERC1271MaliciousMockUpgradeable is IERC1271Upgradeable {
    function isValidSignature(bytes32, bytes memory) public pure override returns (bytes4) {
        assembly {
            mstore(0, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            return(0, 32)
        }
    }
}
