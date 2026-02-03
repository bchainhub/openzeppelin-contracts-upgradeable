// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (metatx/MinimalForwarder.sol)

pragma solidity ^1.1.2;

import "../utils/cryptography/EDDSA.sol";
import "../utils/cryptography/EIP712.sol";

/**
 * @dev Simple minimal forwarder to be used together with an ERC2771 compatible contract.
 */
contract MinimalForwarder is EIP712 {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    bytes32 private constant _TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    mapping(address => uint256) private _nonces;

    constructor() EIP712("MinimalForwarder", "0.0.1") {}

    function getNonce(address from) public view returns (uint256) {
        return _nonces[from];
    }

    function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
        bytes32 structHash = keccak256(
            abi.encode(_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data))
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        (address signer, EDDSA.RecoverError error) = EDDSA.tryRecover(digest, signature);
        return _nonces[req.from] == req.nonce && error == EDDSA.RecoverError.NoError && signer == req.from;
    }

    function execute(ForwardRequest calldata req, bytes calldata signature) public payable returns (bool, bytes memory) {
        require(verify(req, signature), "MinimalForwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;

        (bool success, bytes memory returndata) = req.to.call{gas: req.gas, value: req.value}(
            abi.encodePacked(req.data, req.from)
        );

        if (gasleft() <= req.gas / 63) {
            assembly {
                invalid()
            }
        }

        return (success, returndata);
    }
}
