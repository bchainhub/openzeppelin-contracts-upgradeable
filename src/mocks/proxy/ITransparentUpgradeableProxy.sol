// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../../interfaces/IERC1967Upgradeable.sol";

interface ITransparentUpgradeableProxyMock is IERC1967Upgradeable {
    function admin() external view returns (address);

    function implementation() external view returns (address);

    function changeAdmin(address) external;

    function upgradeTo(address) external;

    function upgradeToAndCall(address, bytes memory) external payable;
}
