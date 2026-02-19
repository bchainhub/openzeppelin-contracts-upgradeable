// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/token/CRC20/CRC20Upgradeable.sol";
import "../../../src/utils/ChecksumUpgradeable.sol";

contract CRC20UpgradeableMock is CRC20Upgradeable {
    function initialize(string memory name_, string memory symbol_) external initializer {
        __CRC20_init(name_, symbol_);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }

    function transferInternal(address from, address to, uint256 amount) external {
        _transfer(from, to, amount);
    }

    function approveInternal(address owner, address spender, uint256 amount) external {
        _approve(owner, spender, amount);
    }
}

contract CRC20DecimalsUpgradeableMock is CRC20Upgradeable {
    uint8 private _decimalsValue;

    function initialize(string memory name_, string memory symbol_, uint8 decimals_) external initializer {
        __CRC20_init(name_, symbol_);
        _decimalsValue = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimalsValue;
    }
}

contract CRC20UpgradeableTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    CRC20UpgradeableMock private _token;

    address private _initialHolder;
    address private _recipient;
    address private _anotherAccount;
    address private _zeroChecksum;

    string private constant _NAME = "My Token";
    string private constant _SYMBOL = "MTKN";
    uint256 private constant _INITIAL_SUPPLY = 100;

    function setUp() public {
        _token = new CRC20UpgradeableMock();
        _token.initialize(_NAME, _SYMBOL);
        _initialHolder = makeAddr("initialHolder");
        _recipient = makeAddr("recipient");
        _anotherAccount = makeAddr("anotherAccount");
        _zeroChecksum = ChecksumUpgradeable.zeroAddress();

        _token.mint(_initialHolder, _INITIAL_SUPPLY);
    }

    function testHasName() public {
        assertEq(_token.name(), _NAME);
    }

    function testHasSymbol() public {
        assertEq(_token.symbol(), _SYMBOL);
    }

    function testHas18Decimals() public {
        assertEq(_token.decimals(), 18);
    }

    function testCanSetDecimalsDuringInit() public {
        CRC20DecimalsUpgradeableMock token = new CRC20DecimalsUpgradeableMock();
        token.initialize(_NAME, _SYMBOL, 6);
        assertEq(token.decimals(), 6);
    }

    function testTotalSupply() public {
        assertEq(_token.totalSupply(), _INITIAL_SUPPLY);
    }

    function testBalanceOfEmptyAccount() public {
        assertEq(_token.balanceOf(_anotherAccount), 0);
    }

    function testBalanceOfHolder() public {
        assertEq(_token.balanceOf(_initialHolder), _INITIAL_SUPPLY);
    }

    function testTransferInsufficientBalance() public {
        vm.prank(_anotherAccount);
        vm.expectRevert(bytes("CRC20: transfer amount exceeds balance"));
        _token.transfer(_recipient, _INITIAL_SUPPLY + 1);
    }

    function testTransferAllBalance() public {
        vm.prank(_initialHolder);
        _token.transfer(_recipient, _INITIAL_SUPPLY);
        assertEq(_token.balanceOf(_initialHolder), 0);
        assertEq(_token.balanceOf(_recipient), _INITIAL_SUPPLY);
    }

    function testTransferToZeroAddressReverts() public {
        vm.prank(_initialHolder);
        vm.expectRevert(bytes("CRC20: transfer to the zero address"));
        _token.transfer(address(0), _INITIAL_SUPPLY);
    }

    function testTransferToChecksummedZeroAddressReverts() public {
        vm.prank(_initialHolder);
        vm.expectRevert(bytes("CRC20: transfer to the zero address"));
        _token.transfer(_zeroChecksum, _INITIAL_SUPPLY);
    }

    function testTransferFromWithEnoughAllowanceAndBalance() public {
        vm.prank(_initialHolder);
        _token.approve(_recipient, _INITIAL_SUPPLY);

        vm.prank(_recipient);
        _token.transferFrom(_initialHolder, _anotherAccount, _INITIAL_SUPPLY);

        assertEq(_token.balanceOf(_initialHolder), 0);
        assertEq(_token.balanceOf(_anotherAccount), _INITIAL_SUPPLY);
        assertEq(_token.allowance(_initialHolder, _recipient), 0);
    }

    function testTransferFromInsufficientAllowance() public {
        vm.prank(_initialHolder);
        _token.approve(_recipient, _INITIAL_SUPPLY - 1);

        vm.prank(_recipient);
        vm.expectRevert(bytes("CRC20: insufficient allowance"));
        _token.transferFrom(_initialHolder, _anotherAccount, _INITIAL_SUPPLY);
    }

    function testTransferFromFromZeroAddressReverts() public {
        vm.prank(_recipient);
        vm.expectRevert(bytes("CRC20: transfer from the zero address"));
        _token.transferFrom(address(0), _recipient, 0);
    }

    function testApproveToZeroAddressReverts() public {
        vm.prank(_initialHolder);
        vm.expectRevert(bytes("CRC20: approve to the zero address"));
        _token.approve(address(0), _INITIAL_SUPPLY);
    }

    function testDecreaseAllowanceRevertsWhenTooMuch() public {
        vm.prank(_initialHolder);
        _token.approve(_recipient, _INITIAL_SUPPLY);

        vm.prank(_initialHolder);
        vm.expectRevert(bytes("CRC20: decreased allowance below zero"));
        _token.decreaseAllowance(_recipient, _INITIAL_SUPPLY + 1);
    }

    function testIncreaseAllowanceWorks() public {
        vm.prank(_initialHolder);
        _token.increaseAllowance(_recipient, _INITIAL_SUPPLY);
        assertEq(_token.allowance(_initialHolder, _recipient), _INITIAL_SUPPLY);
    }

    function testMintRejectsZeroAddresses() public {
        vm.expectRevert(bytes("CRC20: mint to the zero address"));
        _token.mint(address(0), 50);

        vm.expectRevert(bytes("CRC20: mint to the zero address"));
        _token.mint(_zeroChecksum, 50);
    }

    function testMintUpdatesSupplyAndBalanceAndEmitsTransfer() public {
        uint256 amount = 50;
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), _recipient, amount);
        _token.mint(_recipient, amount);

        assertEq(_token.totalSupply(), _INITIAL_SUPPLY + amount);
        assertEq(_token.balanceOf(_recipient), amount);
    }

    function testBurnRejectsZeroAddresses() public {
        vm.expectRevert(bytes("CRC20: burn from the zero address"));
        _token.burn(address(0), 1);

        vm.expectRevert(bytes("CRC20: burn from the zero address"));
        _token.burn(_zeroChecksum, 1);
    }

    function testBurnRejectsAmountExceedingBalance() public {
        vm.expectRevert(bytes("CRC20: burn amount exceeds balance"));
        _token.burn(_initialHolder, _INITIAL_SUPPLY + 1);
    }

    function testTransferInternalFromZeroAddressReverts() public {
        vm.expectRevert(bytes("CRC20: transfer from the zero address"));
        _token.transferInternal(address(0), _recipient, _INITIAL_SUPPLY);
    }

    function testTransferInternalToZeroAddressReverts() public {
        vm.expectRevert(bytes("CRC20: transfer to the zero address"));
        _token.transferInternal(_initialHolder, address(0), _INITIAL_SUPPLY);
    }
}
