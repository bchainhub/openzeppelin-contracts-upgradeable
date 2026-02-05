// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20CappedUpgradeable.sol";

contract CRC20CappedUpgradeableMock is CRC20CappedUpgradeable {
    function initialize(string memory name_, string memory symbol_, uint256 cap_) external initializer {
        __CRC20_init(name_, symbol_);
        __CRC20Capped_init(cap_);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CRC20CappedUpgradeableTest is Test {
    CRC20CappedUpgradeableMock private _token;

    function testRequiresNonZeroCap() public {
        _token = new CRC20CappedUpgradeableMock();
        vm.expectRevert(bytes("CRC20Capped: cap is 0"));
        _token.initialize("My Token", "MTKN", 0);
    }

    function testStartsWithCorrectCap() public {
        _token = new CRC20CappedUpgradeableMock();
        _token.initialize("My Token", "MTKN", 1000 ether);
        assertEq(_token.cap(), 1000 ether);
    }

    function testRevertsWhenCapReached() public {
        _token = new CRC20CappedUpgradeableMock();
        _token.initialize("My Token", "MTKN", 1000 ether);
        _token.mint(makeAddr("a"), 1000 ether);
        vm.expectRevert(bytes("CRC20Capped: cap exceeded"));
        _token.mint(makeAddr("a"), 1);
    }
}
