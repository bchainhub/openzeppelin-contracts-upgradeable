// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20Capped.sol";

contract CRC20CappedMock is CRC20Capped {
    constructor(string memory name_, string memory symbol_, uint256 cap_) CRC20(name_, symbol_) CRC20Capped(cap_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CRC20CappedTest is Test {
    CRC20CappedMock private _token;

    string private constant _NAME = "My Token";
    string private constant _SYMBOL = "MTKN";

    uint256 private constant _CAP = 1000 ether;

    function testRequiresNonZeroCap() public {
        vm.expectRevert(bytes("CRC20Capped: cap is 0"));
        new CRC20CappedMock(_NAME, _SYMBOL, 0);
    }

    function testStartsWithCorrectCap() public {
        _token = new CRC20CappedMock(_NAME, _SYMBOL, _CAP);
        assertEq(_token.cap(), _CAP);
    }

    function testMintsWhenAmountLessThanCap() public {
        _token = new CRC20CappedMock(_NAME, _SYMBOL, _CAP);
        _token.mint(address(0x1111), _CAP - 1);
        assertEq(_token.totalSupply(), _CAP - 1);
    }

    function testRevertsWhenAmountExceedsCap() public {
        _token = new CRC20CappedMock(_NAME, _SYMBOL, _CAP);
        _token.mint(address(0x1111), _CAP - 1);
        vm.expectRevert(bytes("CRC20Capped: cap exceeded"));
        _token.mint(address(0x1111), 2);
    }

    function testRevertsWhenCapReached() public {
        _token = new CRC20CappedMock(_NAME, _SYMBOL, _CAP);
        _token.mint(address(0x1111), _CAP);
        vm.expectRevert(bytes("CRC20Capped: cap exceeded"));
        _token.mint(address(0x1111), 1);
    }
}
