// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

contract BadBeaconNoImplUpgradeable {}

contract BadBeaconNotContractUpgradeable {
    function implementation() external pure returns (address) {
        return address(0x1);
    }
}
