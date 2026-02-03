// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/proxy/Clones.sol";
import "../../src/utils/Checksum.sol";

contract DummyImplementation {
    uint256 public value;
    string public text;
    uint256[] public values;

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
}

contract ClonesFactory {
    function clone(address implementation) external returns (address) {
        return Clones.clone(implementation);
    }

    function cloneDeterministic(address implementation, bytes32 salt) external returns (address) {
        return Clones.cloneDeterministic(implementation, salt);
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, salt);
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, salt, deployer);
    }
}

contract ClonesTest is Test {
    DummyImplementation private _implementation;
    ClonesFactory private _factory;

    function setUp() public {
        _implementation = new DummyImplementation();
        _factory = new ClonesFactory();
    }

    function testCloneNonPayableNoValue() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializeNonPayable()");
        _expectInit(proxy, data, 0, true, 10, 0);
    }

    function testCloneNonPayableWithValueReverts() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializeNonPayable()");
        _expectInit(proxy, data, 10e5, false, 0, 0);
    }

    function testClonePayableNoValue() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializePayable()");
        _expectInit(proxy, data, 0, true, 100, 0);
    }

    function testClonePayableWithValue() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializePayable()");
        _expectInit(proxy, data, 10e5, true, 100, 10e5);
    }

    function testCloneNonPayableWithParamNoValue() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        _expectInit(proxy, data, 0, true, 10, 0);
    }

    function testCloneNonPayableWithParamValueReverts() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializeNonPayableWithValue(uint256)", 10);
        _expectInit(proxy, data, 10e5, false, 0, 0);
    }

    function testClonePayableWithParamNoValue() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 42);
        _expectInit(proxy, data, 0, true, 42, 0);
    }

    function testClonePayableWithParamValue() public {
        address proxy = _factory.clone(address(_implementation));
        bytes memory data = abi.encodeWithSignature("initializePayableWithValue(uint256)", 42);
        _expectInit(proxy, data, 10e5, true, 42, 10e5);
    }

    function testCloneDeterministicAddressAlreadyUsed() public {
        bytes32 salt = keccak256("salt");
        _factory.cloneDeterministic(address(_implementation), salt);
        vm.expectRevert(bytes("ERC1167: create2 failed"));
        _factory.cloneDeterministic(address(_implementation), salt);
    }

    function testPredictDeterministicAddress() public {
        bytes32 salt = keccak256("salt-2");
        address predicted = _factory.predictDeterministicAddress(address(_implementation), salt);
        address expected = _computeCreate2Address(salt, _cloneBytecode(address(_implementation)), address(_factory));
        assertEq(predicted, expected);

        address deployed = _factory.cloneDeterministic(address(_implementation), salt);
        assertEq(deployed, expected);
    }

    function _expectInit(
        address proxy,
        bytes memory data,
        uint256 value,
        bool shouldSucceed,
        uint256 expectedValue,
        uint256 expectedBalance
    ) private {
        (bool ok,) = proxy.call{value: value}(data);
        assertEq(ok, shouldSucceed);
        assertEq(proxy.balance, expectedBalance);
        if (shouldSucceed) {
            assertEq(DummyImplementation(proxy).value(), expectedValue);
        } else {
            assertEq(DummyImplementation(proxy).value(), 0);
        }
    }

    function _cloneBytecode(address implementation) private pure returns (bytes memory) {
        return abi.encodePacked(
            hex"3d602f80600a3d3981f3",
            hex"363d3d373d3d3d363d75",
            bytes22(uint176(implementation)),
            hex"5af43d82803e903d91602d57fd5bf3"
        );
    }

    function _computeCreate2Address(bytes32 salt, bytes memory bytecode, address deployer) private view returns (address) {
        bytes32 bytecodeHash = keccak256(bytecode);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return Checksum.toIcan(uint160(uint256(hash)));
    }
}
