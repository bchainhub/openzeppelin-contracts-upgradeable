// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

contract BadBeaconNoImpl {}

contract BadBeaconNotContract {
    function implementation() external pure returns (address) {
        return address(0x1);
    }
}
