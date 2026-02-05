// SPDX-License-Identifier: MIT

pragma solidity ^1.1.2;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

contract ContextMockUpgradeable is Initializable, ContextUpgradeable {
    event Sender(address sender);

    function __ContextMock_init() internal onlyInitializing {}

    function __ContextMock_init_unchained() internal onlyInitializing {}

    function msgSender() public {
        emit Sender(_msgSender());
    }

    event Data(bytes data, uint256 integerValue, string stringValue);

    function msgData(uint256 integerValue, string memory stringValue) public {
        emit Data(_msgData(), integerValue, stringValue);
    }

    event DataShort(bytes data);

    function msgDataShort() public {
        emit DataShort(_msgData());
    }

    uint256[50] private __gap;
}

contract ContextMockCallerUpgradeable is Initializable {
    function __ContextMockCaller_init() internal onlyInitializing {}

    function __ContextMockCaller_init_unchained() internal onlyInitializing {}

    function callSender(ContextMockUpgradeable context) public {
        context.msgSender();
    }

    function callData(ContextMockUpgradeable context, uint256 integerValue, string memory stringValue) public {
        context.msgData(integerValue, stringValue);
    }

    uint256[50] private __gap;
}
