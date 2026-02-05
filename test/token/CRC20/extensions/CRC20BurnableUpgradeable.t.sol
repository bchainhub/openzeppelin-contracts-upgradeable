// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/extensions/CRC20BurnableUpgradeable.sol";

contract CRC20BurnableUpgradeableMock is CRC20BurnableUpgradeable {
    function initialize(string memory name_, string memory symbol_) external initializer {
        __CRC20_init(name_, symbol_);
        __CRC20Burnable_init();
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CRC20BurnableUpgradeableTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    CRC20BurnableUpgradeableMock private _token;
    address private _owner;
    address private _burner;

    function setUp() public {
        _owner = makeAddr("owner");
        _burner = makeAddr("burner");

        _token = new CRC20BurnableUpgradeableMock();
        _token.initialize("My Token", "MTKN");
        _token.mint(_owner, 1000);
    }

    function testBurnZeroAmount() public {
        vm.prank(_owner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 0);
        _token.burn(0);
        assertEq(_token.balanceOf(_owner), 1000);
    }

    function testBurnNonZeroAmount() public {
        vm.prank(_owner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 100);
        _token.burn(100);
        assertEq(_token.balanceOf(_owner), 900);
    }

    function testBurnFromNonZeroAmount() public {
        vm.prank(_owner);
        _token.approve(_burner, 300);

        vm.prank(_burner);
        vm.expectEmit(true, true, false, true);
        emit Transfer(_owner, address(0), 100);
        _token.burnFrom(_owner, 100);

        assertEq(_token.balanceOf(_owner), 900);
        assertEq(_token.allowance(_owner, _burner), 200);
    }

    function testBurnFromExceedsAllowance() public {
        vm.prank(_owner);
        _token.approve(_burner, 100);

        vm.prank(_burner);
        vm.expectRevert(bytes("CRC20: insufficient allowance"));
        _token.burnFrom(_owner, 101);
    }
}
