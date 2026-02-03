// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../src/utils/Create2.sol";
import "../../src/utils/Checksum.sol";

contract Create2Mock {
    event Deployed(address addr);

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) external payable returns (address) {
        address addr = Create2.deploy(amount, salt, bytecode);
        emit Deployed(addr);
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) external view returns (address) {
        return Create2.computeAddress(salt, bytecodeHash);
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) external view returns (address) {
        return Create2.computeAddress(salt, bytecodeHash, deployer);
    }
}

contract Dummy {
    uint256 public value;
    address public owner;

    constructor(uint256 value_, address owner_) payable {
        value = value_;
        owner = owner_;
    }
}

contract Create2Test is Test {
    Create2Mock private _factory;
    bytes32 private _salt;

    function setUp() public {
        _factory = new Create2Mock();
        _salt = keccak256(abi.encodePacked("salt message"));
    }

    function testComputeAddressDefaultDeployer() public {
        bytes memory bytecode = _dummyBytecode(7, address(0xBEEF));
        bytes32 bytecodeHash = keccak256(bytecode);

        address onChain = _factory.computeAddress(_salt, bytecodeHash);
        address offChain = _computeCreate2Address(_salt, bytecode, address(_factory));

        assertEq(onChain, offChain);
    }

    function testComputeAddressWithDeployer() public {
        bytes memory bytecode = _dummyBytecode(7, address(0xBEEF));
        bytes32 bytecodeHash = keccak256(bytecode);
        address deployer = address(0xCAFE);

        address onChain = _factory.computeAddress(_salt, bytecodeHash, deployer);
        address offChain = _computeCreate2Address(_salt, bytecode, deployer);

        assertEq(onChain, offChain);
    }

    function testDeploysContractWithConstructorArgs() public {
        bytes memory bytecode = _dummyBytecode(42, address(this));
        address expected = _computeCreate2Address(_salt, bytecode, address(_factory));

        address deployed = _factory.deploy(0, _salt, bytecode);
        assertEq(deployed, expected);

        Dummy instance = Dummy(deployed);
        assertEq(instance.value(), 42);
        assertEq(instance.owner(), address(this));
    }

    function testDeploysContractWithFunds() public {
        uint256 deposit = 2 ether;
        bytes memory bytecode = _dummyBytecode(1, address(this));
        address expected = _computeCreate2Address(_salt, bytecode, address(_factory));

        vm.deal(address(_factory), deposit);
        address deployed = _factory.deploy(deposit, _salt, bytecode);
        assertEq(deployed, expected);
        assertEq(deployed.balance, deposit);
    }

    function testDeployFailsOnExistingAddress() public {
        bytes memory bytecode = _dummyBytecode(1, address(this));
        _factory.deploy(0, _salt, bytecode);

        vm.expectRevert(bytes("Create2: Failed on deploy"));
        _factory.deploy(0, _salt, bytecode);
    }

    function testDeployFailsOnEmptyBytecode() public {
        vm.expectRevert(bytes("Create2: bytecode length is zero"));
        _factory.deploy(0, _salt, new bytes(0));
    }

    function testDeployFailsOnInsufficientBalance() public {
        bytes memory bytecode = _dummyBytecode(1, address(this));
        vm.expectRevert(bytes("Create2: insufficient balance"));
        _factory.deploy(1, _salt, bytecode);
    }

    function _dummyBytecode(uint256 value, address owner) private pure returns (bytes memory) {
        return abi.encodePacked(type(Dummy).creationCode, abi.encode(value, owner));
    }

    function _computeCreate2Address(bytes32 salt, bytes memory bytecode, address deployer) private view returns (address) {
        bytes32 bytecodeHash = keccak256(bytecode);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return Checksum.toIcan(uint160(uint256(hash)));
    }
}
