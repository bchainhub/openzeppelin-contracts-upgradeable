// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/mocks/proxy/ERC1967Proxy.sol";
import "../../../src/mocks/proxy/UUPSUpgradeableMockUpgradeable.sol";
import "../../../src/mocks/proxy/UUPSLegacyUpgradeable.sol";

contract UUPSUpgradeableTest is Test {
    bytes32 private constant IMPLEMENTATION_SLOT = 0x169aa7877a62aec264f92a4c78812101abc42f65cbb20781a5cb4084c2d639d7;

    event Upgraded(address indexed implementation);

    UUPSUpgradeableMockUpgradeable private _implInitial;
    UUPSUpgradeableMockUpgradeable private _implUpgradeOk;
    UUPSUpgradeableUnsafeMockUpgradeable private _implUpgradeUnsafe;
    NonUpgradeableMockUpgradeable private _implUpgradeNonUUPS;
    UUPSUpgradeableMockUpgradeable private _instance;

    function setUp() public {
        _implInitial = new UUPSUpgradeableMockUpgradeable();
        _implUpgradeOk = new UUPSUpgradeableMockUpgradeable();
        _implUpgradeUnsafe = new UUPSUpgradeableUnsafeMockUpgradeable();
        _implUpgradeNonUUPS = new NonUpgradeableMockUpgradeable();

        ERC1967ProxyMock proxy = new ERC1967ProxyMock(address(_implInitial), "");
        _instance = UUPSUpgradeableMockUpgradeable(address(proxy));
    }

    function testUpgradeToUpgradeableImplementation() public {
        vm.expectEmit(true, false, false, true);
        emit Upgraded(address(_implUpgradeOk));
        _instance.upgradeTo(address(_implUpgradeOk));
    }

    function testUpgradeToUpgradeableImplementationWithCall() public {
        assertEq(_instance.current(), 0);

        vm.expectEmit(true, false, false, true);
        emit Upgraded(address(_implUpgradeOk));
        _instance.upgradeToAndCall(address(_implUpgradeOk), abi.encodeWithSignature("increment()"));

        assertEq(_instance.current(), 1);
    }

    function testUpgradeToUnsafeUpgradeableImplementation() public {
        vm.expectEmit(true, false, false, true);
        emit Upgraded(address(_implUpgradeUnsafe));
        _instance.upgradeTo(address(_implUpgradeUnsafe));
    }

    function testRejectUpgradeToNonUUPSImplementation() public {
        vm.expectRevert(bytes("ERC1967Upgrade: new implementation is not UUPS"));
        _instance.upgradeTo(address(_implUpgradeNonUUPS));
    }

    function testRejectProxyAddressAsImplementation() public {
        ERC1967ProxyMock otherProxy = new ERC1967ProxyMock(address(_implInitial), "");
        vm.expectRevert(bytes("ERC1967Upgrade: new implementation is not UUPS"));
        _instance.upgradeTo(address(otherProxy));
    }

    function testUpgradeFromLegacyImplementation() public {
        UUPSUpgradeableLegacyMockUpgradeable legacyImpl = new UUPSUpgradeableLegacyMockUpgradeable();
        ERC1967ProxyMock legacyProxy = new ERC1967ProxyMock(address(legacyImpl), "");
        UUPSUpgradeableLegacyMockUpgradeable legacyInstance = UUPSUpgradeableLegacyMockUpgradeable(address(legacyProxy));

        vm.expectEmit(true, false, false, true);
        emit Upgraded(address(_implInitial));
        legacyInstance.upgradeTo(address(_implInitial));

        bytes32 raw = vm.load(address(legacyProxy), IMPLEMENTATION_SLOT);
        address impl = address(uint176(uint256(raw)));
        assertEq(impl, address(_implInitial));
    }
}
