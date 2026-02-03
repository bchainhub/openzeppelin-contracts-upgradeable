// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/proxy/ERC1967/ERC1967Proxy.sol";
import "../../../src/mocks/proxy/UUPSUpgradeableMock.sol";
import "../../../src/mocks/proxy/UUPSLegacy.sol";

contract UUPSUpgradeableTest is Test {
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x169aa7877a62aec264f92a4c78812101abc42f65cbb20781a5cb4084c2d639d7;

    event Upgraded(address indexed implementation);

    UUPSUpgradeableMock private _implInitial;
    UUPSUpgradeableMock private _implUpgradeOk;
    UUPSUpgradeableUnsafeMock private _implUpgradeUnsafe;
    NonUpgradeableMock private _implUpgradeNonUUPS;
    UUPSUpgradeableMock private _instance;

    function setUp() public {
        _implInitial = new UUPSUpgradeableMock();
        _implUpgradeOk = new UUPSUpgradeableMock();
        _implUpgradeUnsafe = new UUPSUpgradeableUnsafeMock();
        _implUpgradeNonUUPS = new NonUpgradeableMock();

        ERC1967Proxy proxy = new ERC1967Proxy(address(_implInitial), "");
        _instance = UUPSUpgradeableMock(address(proxy));
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
        ERC1967Proxy otherProxy = new ERC1967Proxy(address(_implInitial), "");
        vm.expectRevert(bytes("ERC1967Upgrade: new implementation is not UUPS"));
        _instance.upgradeTo(address(otherProxy));
    }

    function testUpgradeFromLegacyImplementation() public {
        UUPSUpgradeableLegacyMock legacyImpl = new UUPSUpgradeableLegacyMock();
        ERC1967Proxy legacyProxy = new ERC1967Proxy(address(legacyImpl), "");
        UUPSUpgradeableLegacyMock legacyInstance = UUPSUpgradeableLegacyMock(address(legacyProxy));

        vm.expectEmit(true, false, false, true);
        emit Upgraded(address(_implInitial));
        legacyInstance.upgradeTo(address(_implInitial));

        bytes32 raw = vm.load(address(legacyProxy), IMPLEMENTATION_SLOT);
        address impl = address(uint176(uint256(raw)));
        assertEq(impl, address(_implInitial));
    }
}
