// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20PausableUpgradeable.sol";

contract CRC20PausableUpgradeableMock is CRC20PausableUpgradeable {
    function initialize(string memory name_, string memory symbol_) external initializer {
        __CRC20_init(name_, symbol_);
        __CRC20Pausable_init();
    }

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

contract CRC20PausableUpgradeableTest is Test {
    CRC20PausableUpgradeableMock private _token;
    address private _holder;
    address private _recipient;
    address private _anotherAccount;

    function setUp() public {
        _holder = makeAddr("holder");
        _recipient = makeAddr("recipient");
        _anotherAccount = makeAddr("anotherAccount");

        _token = new CRC20PausableUpgradeableMock();
        _token.initialize("My Token", "MTKN");
        _token.mint(_holder, 100);
    }

    function testTransferWhenUnpaused() public {
        vm.prank(_holder);
        _token.transfer(_recipient, 100);
        assertEq(_token.balanceOf(_holder), 0);
        assertEq(_token.balanceOf(_recipient), 100);
    }

    function testRevertsTransferWhenPaused() public {
        _token.pause();
        vm.prank(_holder);
        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.transfer(_recipient, 100);
    }

    function testRevertsTransferFromWhenPaused() public {
        vm.prank(_holder);
        _token.approve(_anotherAccount, 40);
        _token.pause();

        vm.prank(_anotherAccount);
        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.transferFrom(_holder, _recipient, 40);
    }

    function testRevertsMintWhenPaused() public {
        _token.pause();
        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.mint(_recipient, 42);
    }

    function testRevertsBurnWhenPaused() public {
        _token.pause();
        vm.expectRevert(bytes("CRC20Pausable: token transfer while paused"));
        _token.burn(_holder, 42);
    }
}
