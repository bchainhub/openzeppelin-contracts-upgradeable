// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../utils/Context.sol";

contract ReentrancyAttack is Context {
    function callSender(bytes4 data) public {
        (bool success, ) = _msgSender().call(abi.encodeWithSelector(data));
        require(success, "ReentrancyAttack: failed call");
    }
}
