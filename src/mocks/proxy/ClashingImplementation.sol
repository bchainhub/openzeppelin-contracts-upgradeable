// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

contract ClashingImplementationUpgradeable {
    function admin() external payable returns (address) {
        return address(uint176(0x0000000000000000000000000000000011111142));
    }

    function delegatedFunction() external pure returns (bool) {
        return true;
    }
}
