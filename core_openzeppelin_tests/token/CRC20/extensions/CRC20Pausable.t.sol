// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20Pausable.sol";

contract CRC20PausableMock is CRC20Pausable {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) {}

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract CRC20PausableTest is Test {
    CRC20PausableMock private _token;

    address private _holder;
    address private _recipient;
    address private _anotherAccount;

    uint256 private constant _INITIAL_SUPPLY = 100;

    function setUp() public {
        _holder = address(0x1111);
        _recipient = address(0x2222);
        _anotherAccount = address(0x3333);

        _token = new CRC20PausableMock("My Token", "MTKN");
        _token.mint(_holder, _INITIAL_SUPPLY);
    }

    function testTransferWhenUnpaused() public {
        vm.prank(_holder);
        _token.transfer(_recipient, _INITIAL_SUPPLY);

        assertEq(_token.balanceOf(_holder), 0);
        assertEq(_token.balanceOf(_recipient), _INITIAL_SUPPLY);
    }

    function testTransferWhenPausedThenUnpaused() public {
        _token.pause();
        _token.unpause();

        vm.prank(_holder);
        _token.transfer(_recipient, _INITIAL_SUPPLY);

        assertEq(_token.balanceOf(_holder), 0);
        assertEq(_token.balanceOf(_recipient), _INITIAL_SUPPLY);
    }

    function testRevertsTransferWhenPaused() public {
        _token.pause();

        vm.prank(_holder);
        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.transfer(_recipient, _INITIAL_SUPPLY);
    }

    function testTransferFromWhenUnpaused() public {
        uint256 allowance = 40;
        vm.prank(_holder);
        _token.approve(_anotherAccount, allowance);

        vm.prank(_anotherAccount);
        _token.transferFrom(_holder, _recipient, allowance);

        assertEq(_token.balanceOf(_recipient), allowance);
        assertEq(_token.balanceOf(_holder), _INITIAL_SUPPLY - allowance);
    }

    function testTransferFromWhenPausedThenUnpaused() public {
        uint256 allowance = 40;
        vm.prank(_holder);
        _token.approve(_anotherAccount, allowance);

        _token.pause();
        _token.unpause();

        vm.prank(_anotherAccount);
        _token.transferFrom(_holder, _recipient, allowance);

        assertEq(_token.balanceOf(_recipient), allowance);
        assertEq(_token.balanceOf(_holder), _INITIAL_SUPPLY - allowance);
    }

    function testRevertsTransferFromWhenPaused() public {
        uint256 allowance = 40;
        vm.prank(_holder);
        _token.approve(_anotherAccount, allowance);

        _token.pause();

        vm.prank(_anotherAccount);
        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.transferFrom(_holder, _recipient, allowance);
    }

    function testMintWhenUnpaused() public {
        _token.mint(_recipient, 42);
        assertEq(_token.balanceOf(_recipient), 42);
    }

    function testMintWhenPausedThenUnpaused() public {
        _token.pause();
        _token.unpause();

        _token.mint(_recipient, 42);
        assertEq(_token.balanceOf(_recipient), 42);
    }

    function testRevertsMintWhenPaused() public {
        _token.pause();

        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.mint(_recipient, 42);
    }

    function testBurnWhenUnpaused() public {
        _token.burn(_holder, 42);
        assertEq(_token.balanceOf(_holder), _INITIAL_SUPPLY - 42);
    }

    function testBurnWhenPausedThenUnpaused() public {
        _token.pause();
        _token.unpause();

        _token.burn(_holder, 42);
        assertEq(_token.balanceOf(_holder), _INITIAL_SUPPLY - 42);
    }

    function testRevertsBurnWhenPaused() public {
        _token.pause();

        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.burn(_holder, 42);
    }
}
