// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/mocks/proxy/ERC1967Proxy.sol";

contract DummyImplementationProxyUpgradeable {
    uint256 public value;

    function initializeNonPayable() public {
        value = 10;
    }

    function initializePayable() public payable {
        value = 100;
    }

    function initializeNonPayableWithValue(uint256 _value) public {
        value = _value;
    }

    function initializePayableWithValue(uint256 _value) public payable {
        value = _value;
    }

    function reverts() public pure {
        require(false, "DummyImplementation reverted");
    }
}

contract ERC1967ProxyUpgradeableTest is Test {
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x169aa7877a62aec264f92a4c78812101abc42f65cbb20781a5cb4084c2d639d7;

    DummyImplementationProxyUpgradeable private _implementation;

    function setUp() public {
        _implementation = new DummyImplementationProxyUpgradeable();
    }

    function testCannotInitializeWithNonContract() public {
        vm.expectRevert();
        new ERC1967ProxyMock(address(0xBEEF), "");
    }

    function testInitWithoutParamsNoValue() public {
        ERC1967ProxyMock proxy = _deployProxy("", 0);
        _assertProxyInitialization(proxy, 0, 0);
    }

    function testInitWithoutParamsWithValue() public {
        uint256 value = 10e5;
        ERC1967ProxyMock proxy = _deployProxy("", value);
        _assertProxyInitialization(proxy, 0, value);
    }

    function testInitNonPayableNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayable()");
        ERC1967ProxyMock proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 10, 0);
    }

    function testInitNonPayableWithValueReverts() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayable()");
        vm.expectRevert();
        new ERC1967ProxyMock{value: 10e5}(address(_implementation), data);
    }

    function testInitPayableNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayable()");
        ERC1967ProxyMock proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 100, 0);
    }

    function testInitPayableWithValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayable()");
        uint256 value = 10e5;
        ERC1967ProxyMock proxy = _deployProxy(data, value);
        _assertProxyInitialization(proxy, 100, value);
    }

    function testInitNonPayableWithParamNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        ERC1967ProxyMock proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 10, 0);
    }

    function testInitNonPayableWithParamValueReverts() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        vm.expectRevert();
        new ERC1967ProxyMock{value: 10e5}(address(_implementation), data);
    }

    function testInitPayableWithParamNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 42);
        ERC1967ProxyMock proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 42, 0);
    }

    function testInitPayableWithParamValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 42);
        uint256 value = 10e5;
        ERC1967ProxyMock proxy = _deployProxy(data, value);
        _assertProxyInitialization(proxy, 42, value);
    }

    function testRevertingInitialization() public {
        bytes memory data = abi.encodeWithSignature("reverts()");
        vm.expectRevert(bytes("DummyImplementation reverted"));
        new ERC1967ProxyMock(address(_implementation), data);
    }

    function _deployProxy(bytes memory data, uint256 value) private returns (ERC1967ProxyMock) {
        return new ERC1967ProxyMock{value: value}(address(_implementation), data);
    }

    function _assertProxyInitialization(
        ERC1967ProxyMock proxy,
        uint256 expectedValue,
        uint256 expectedBalance
    ) private {
        bytes32 raw = vm.load(address(proxy), IMPLEMENTATION_SLOT);
        address impl = address(uint176(uint256(raw)));
        assertEq(impl, address(_implementation));
        assertEq(DummyImplementationProxyUpgradeable(address(proxy)).value(), expectedValue);
        assertEq(address(proxy).balance, expectedBalance);
    }
}
