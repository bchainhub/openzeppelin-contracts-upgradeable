// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20Burnable.sol";

contract CRC20BurnableMock is CRC20Burnable {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CRC20BurnableTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    CRC20BurnableMock private _token;

    address private _owner;
    address private _burner;

    string private constant _NAME = "My Token";
    string private constant _SYMBOL = "MTKN";

    uint256 private constant _INITIAL_BALANCE = 1000;

    function setUp() public {
        _owner = address(0x1111);
        _burner = address(0x2222);

        _token = new CRC20BurnableMock(_NAME, _SYMBOL);
        _token.mint(_owner, _INITIAL_BALANCE);
    }

    function testBurnZeroAmount() public {
        vm.prank(_owner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 0);
        _token.burn(0);

        assertEq(_token.balanceOf(_owner), _INITIAL_BALANCE);
    }

    function testBurnNonZeroAmount() public {
        vm.prank(_owner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 100);
        _token.burn(100);

        assertEq(_token.balanceOf(_owner), _INITIAL_BALANCE - 100);
    }

    function testBurnExceedsBalance() public {
        vm.prank(_owner);
        vm.expectRevert(bytes("CRC20: burn amount exceeds balance"));
        _token.burn(_INITIAL_BALANCE + 1);
    }

    function testBurnFromZeroAmount() public {
        vm.prank(_owner);
        _token.approve(_burner, 0);

        vm.prank(_burner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 0);
        _token.burnFrom(_owner, 0);

        assertEq(_token.balanceOf(_owner), _INITIAL_BALANCE);
        assertEq(_token.allowance(_owner, _burner), 0);
    }

    function testBurnFromNonZeroAmount() public {
        vm.prank(_owner);
        _token.approve(_burner, 300);

        vm.prank(_burner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 100);
        _token.burnFrom(_owner, 100);

        assertEq(_token.balanceOf(_owner), _INITIAL_BALANCE - 100);
        assertEq(_token.allowance(_owner, _burner), 200);
    }

    function testBurnFromExceedsBalance() public {
        vm.prank(_owner);
        _token.approve(_burner, _INITIAL_BALANCE + 1);

        vm.prank(_burner);
        vm.expectRevert(bytes("CRC20: burn amount exceeds balance"));
        _token.burnFrom(_owner, _INITIAL_BALANCE + 1);
    }

    function testBurnFromExceedsAllowance() public {
        vm.prank(_owner);
        _token.approve(_burner, 100);

        vm.prank(_burner);
        vm.expectRevert(bytes("CRC20: insufficient allowance"));
        _token.burnFrom(_owner, 101);
    }
}
