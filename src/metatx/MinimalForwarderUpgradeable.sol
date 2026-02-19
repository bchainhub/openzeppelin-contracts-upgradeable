// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (metatx/MinimalForwarder.sol)

pragma solidity ^1.1.2;

import "../utils/cryptography/EDDSAUpgradeable.sol";
import "../utils/cryptography/EIP712Upgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

/**
 * @dev Simple minimal forwarder to be used together with an ERC2771 compatible contract.
 */
contract MinimalForwarderUpgradeable is Initializable, EIP712Upgradeable {
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

    function initialize() external initializer {
        __MinimalForwarder_init();
    }

    function __MinimalForwarder_init() internal onlyInitializing {
        __EIP712_init("MinimalForwarder", "0.0.1");
    }

    function __MinimalForwarder_init_unchained() internal onlyInitializing {}

    function getNonce(address from) public view returns (uint256) {
        return _nonces[from];
    }

    function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
        bytes32 structHash =
            keccak256(abi.encode(_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data)));
        bytes32 digest = _hashTypedDataV4(structHash);
        (address signer, EDDSAUpgradeable.RecoverError error) = EDDSAUpgradeable.tryRecover(digest, signature);
        return _nonces[req.from] == req.nonce && error == EDDSAUpgradeable.RecoverError.NoError && signer == req.from;
    }

    function execute(ForwardRequest calldata req, bytes calldata signature)
        public
        payable
        returns (bool, bytes memory)
    {
        require(verify(req, signature), "MinimalForwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;

        (bool success, bytes memory returndata) =
            req.to.call{gas: req.gas, value: req.value}(abi.encodePacked(req.data, req.from));

        if (gasleft() <= req.gas / 63) {
            assembly {
                invalid()
            }
        }

        return (success, returndata);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
