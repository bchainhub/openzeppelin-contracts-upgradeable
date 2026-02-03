// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/proxy/ERC1967/ERC1967Proxy.sol";
import "../../../src/proxy/ERC1967/ERC1967Upgrade.sol";

contract DummyImplementation {
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

contract ERC1967UpgradeHarness is ERC1967Upgrade {
    function implementationSlot() external pure returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    function adminSlot() external pure returns (bytes32) {
        return _ADMIN_SLOT;
    }

    function beaconSlot() external pure returns (bytes32) {
        return _BEACON_SLOT;
    }

    function rollbackSlot() external pure returns (bytes32) {
        return _ROLLBACK_SLOT;
    }
}

contract ERC1967ProxyTest is Test {
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x169aa7877a62aec264f92a4c78812101abc42f65cbb20781a5cb4084c2d639d7;
    bytes32 private constant ADMIN_SLOT =
        0x5846d050da0e75d43b6055ae3cd6c2c65e1941ccb45afff84b891ff0c7a8e50e;
    bytes32 private constant BEACON_SLOT =
        0x79d0e26f0ed6a26bf96d37944c615e11aedbfafe56e064339e13dad9525cda31;
    bytes32 private constant ROLLBACK_SLOT =
        0x9918ff29762f88fdc924c0a0ba5589b288a6baef366b4981f9a6f4309baada55;

    DummyImplementation private _implementation;

    function setUp() public {
        _implementation = new DummyImplementation();
    }

    function testSlotHashImplementation() public {
        bytes32 hashed = keccak256(bytes("eip1967.proxy.implementation"));
        bytes32 computed = bytes32(uint256(hashed) - 1);
        assertEq(computed, IMPLEMENTATION_SLOT);

        ERC1967UpgradeHarness harness = new ERC1967UpgradeHarness();
        assertEq(harness.implementationSlot(), IMPLEMENTATION_SLOT);
    }

    function testSlotHashAdmin() public {
        bytes32 hashed = keccak256(bytes("eip1967.proxy.admin"));
        bytes32 computed = bytes32(uint256(hashed) - 1);
        assertEq(computed, ADMIN_SLOT);

        ERC1967UpgradeHarness harness = new ERC1967UpgradeHarness();
        assertEq(harness.adminSlot(), ADMIN_SLOT);
    }

    function testSlotHashBeacon() public {
        bytes32 hashed = keccak256(bytes("eip1967.proxy.beacon"));
        bytes32 computed = bytes32(uint256(hashed) - 1);
        assertEq(computed, BEACON_SLOT);

        ERC1967UpgradeHarness harness = new ERC1967UpgradeHarness();
        assertEq(harness.beaconSlot(), BEACON_SLOT);
    }

    function testSlotHashRollback() public {
        bytes32 hashed = keccak256(bytes("eip1967.proxy.rollback"));
        bytes32 computed = bytes32(uint256(hashed) - 1);
        assertEq(computed, ROLLBACK_SLOT);

        ERC1967UpgradeHarness harness = new ERC1967UpgradeHarness();
        assertEq(harness.rollbackSlot(), ROLLBACK_SLOT);
    }

    function testCannotInitializeWithNonContract() public {
        vm.expectRevert();
        new ERC1967Proxy(address(0xBEEF), "");
    }

    function testInitWithoutParamsNoValue() public {
        ERC1967Proxy proxy = _deployProxy("", 0);
        _assertProxyInitialization(proxy, 0, 0);
    }

    function testInitWithoutParamsWithValue() public {
        uint256 value = 10e5;
        ERC1967Proxy proxy = _deployProxy("", value);
        _assertProxyInitialization(proxy, 0, value);
    }

    function testInitNonPayableNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayable()");
        ERC1967Proxy proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 10, 0);
    }

    function testInitNonPayableWithValueReverts() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayable()");
        vm.expectRevert();
        new ERC1967Proxy{value: 10e5}(address(_implementation), data);
    }

    function testInitPayableNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayable()");
        ERC1967Proxy proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 100, 0);
    }

    function testInitPayableWithValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayable()");
        uint256 value = 10e5;
        ERC1967Proxy proxy = _deployProxy(data, value);
        _assertProxyInitialization(proxy, 100, value);
    }

    function testInitNonPayableWithParamNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        ERC1967Proxy proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 10, 0);
    }

    function testInitNonPayableWithParamValueReverts() public {
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        vm.expectRevert();
        new ERC1967Proxy{value: 10e5}(address(_implementation), data);
    }

    function testInitPayableWithParamNoValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 42);
        ERC1967Proxy proxy = _deployProxy(data, 0);
        _assertProxyInitialization(proxy, 42, 0);
    }

    function testInitPayableWithParamValue() public {
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 42);
        uint256 value = 10e5;
        ERC1967Proxy proxy = _deployProxy(data, value);
        _assertProxyInitialization(proxy, 42, value);
    }

    function testRevertingInitialization() public {
        bytes memory data = abi.encodeWithSignature("reverts()");
        vm.expectRevert(bytes("DummyImplementation reverted"));
        new ERC1967Proxy(address(_implementation), data);
    }

    function _deployProxy(bytes memory data, uint256 value) private returns (ERC1967Proxy) {
        return new ERC1967Proxy{value: value}(address(_implementation), data);
    }

    function _assertProxyInitialization(ERC1967Proxy proxy, uint256 expectedValue, uint256 expectedBalance) private {
        bytes32 raw = vm.load(address(proxy), IMPLEMENTATION_SLOT);
        address impl = address(uint176(uint256(raw)));
        assertEq(impl, address(_implementation));
        assertEq(DummyImplementation(address(proxy)).value(), expectedValue);
        assertEq(address(proxy).balance, expectedBalance);
    }
}
