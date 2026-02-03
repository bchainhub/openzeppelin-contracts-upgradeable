// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../access/Ownable.sol";
import "../interfaces/IERC1271.sol";
import "../utils/cryptography/EDDSA.sol";

contract ERC1271WalletMock is Ownable, IERC1271 {
    constructor(address originalOwner) {
        transferOwnership(originalOwner);
    }

    function isValidSignature(bytes32 hash, bytes memory signature) public view override returns (bytes4 magicValue) {
        return EDDSA.recover(hash, signature) == owner() ? this.isValidSignature.selector : bytes4(0);
    }
}

contract ERC1271MaliciousMock is IERC1271 {
    function isValidSignature(bytes32, bytes memory) public pure override returns (bytes4) {
        assembly {
            mstore(0, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            return(0, 32)
        }
    }
}
