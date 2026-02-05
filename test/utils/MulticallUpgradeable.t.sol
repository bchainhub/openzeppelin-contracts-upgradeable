// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/MulticallUpgradeable.sol";

contract CRC20MulticallMockUpgradeable is MulticallUpgradeable {
    string public name;
    string public symbol;

    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        uint256 balance = _balances[msg.sender];
        require(balance >= amount, "CRC20: transfer amount exceeds balance");
        unchecked {
            _balances[msg.sender] = balance - amount;
        }
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}

contract MulticallUpgradeableTestHelper {
    function checkReturnValues(
        CRC20MulticallMockUpgradeable multicallToken,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        bytes[] memory calls = new bytes[](recipients.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            calls[i] = abi.encodeWithSignature("transfer(address,uint256)", recipients[i], amounts[i]);
        }

        bytes[] memory results = multicallToken.multicall(calls);
        for (uint256 i = 0; i < results.length; i++) {
            require(abi.decode(results[i], (bool)));
        }
    }
}

contract MulticallUpgradeableTest is Test {
    CRC20MulticallMockUpgradeable private _token;
    MulticallUpgradeableTestHelper private _helper;

    address private _deployer;
    address private _alice;
    address private _bob;
    uint256 private constant _AMOUNT = 12000;

    function setUp() public {
        _deployer = address(this);
        _alice = makeAddr("alice");
        _bob = makeAddr("bob");

        _token = new CRC20MulticallMockUpgradeable("name", "symbol");
        _token.mint(_deployer, _AMOUNT);
        _helper = new MulticallUpgradeableTestHelper();
    }

    function testBatchesFunctionCalls() public {
        assertEq(_token.balanceOf(_alice), 0);
        assertEq(_token.balanceOf(_bob), 0);

        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSelector(_token.transfer.selector, _alice, _AMOUNT / 2);
        calls[1] = abi.encodeWithSelector(_token.transfer.selector, _bob, _AMOUNT / 3);

        _token.multicall(calls);

        assertEq(_token.balanceOf(_alice), _AMOUNT / 2);
        assertEq(_token.balanceOf(_bob), _AMOUNT / 3);
    }

    function testReturnsArrayWithResultOfEachCall() public {
        _token.transfer(address(_helper), _AMOUNT);
        assertEq(_token.balanceOf(address(_helper)), _AMOUNT);

        address[] memory recipients = new address[](2);
        recipients[0] = _alice;
        recipients[1] = _bob;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = _AMOUNT / 2;
        amounts[1] = _AMOUNT / 3;

        _helper.checkReturnValues(_token, recipients, amounts);
    }

    function testRevertsPreviousCalls() public {
        assertEq(_token.balanceOf(_alice), 0);

        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSelector(_token.transfer.selector, _alice, _AMOUNT);
        calls[1] = abi.encodeWithSelector(_token.transfer.selector, _bob, _AMOUNT);

        vm.expectRevert(bytes("CRC20: transfer amount exceeds balance"));
        _token.multicall(calls);

        assertEq(_token.balanceOf(_alice), 0);
    }

    function testBubblesUpRevertReasons() public {
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSelector(_token.transfer.selector, _alice, _AMOUNT);
        calls[1] = abi.encodeWithSelector(_token.transfer.selector, _bob, _AMOUNT);

        vm.expectRevert(bytes("CRC20: transfer amount exceeds balance"));
        _token.multicall(calls);
    }
}
