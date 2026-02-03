// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/mocks/InitializableMock.sol";
import "../../../src/mocks/MultipleInheritanceInitializableMocks.sol";

contract InitializableTest is Test {
    event Initialized(uint8 version);

    function testInitializerBeforeAndAfter() public {
        InitializableMock contract_ = new InitializableMock();
        assertEq(contract_.initializerRan(), false);
        assertEq(contract_.isInitializing(), false);

        contract_.initialize();
        assertEq(contract_.initializerRan(), true);
        assertEq(contract_.isInitializing(), false);

        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.initialize();
    }

    function testInitializerNestedAndOnlyInitializing() public {
        InitializableMock contract_ = new InitializableMock();

        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.initializerNested();

        contract_.onlyInitializingNested();
        assertEq(contract_.onlyInitializingRan(), true);
    }

    function testOnlyInitializingOutsideReverts() public {
        InitializableMock contract_ = new InitializableMock();
        vm.expectRevert(bytes("Initializable: contract is not initializing"));
        contract_.initializeOnlyInitializing();
    }

    function testConstructorInitializer() public {
        ConstructorInitializableMock contract_ = new ConstructorInitializableMock();
        assertEq(contract_.initializerRan(), true);
        assertEq(contract_.onlyInitializingRan(), true);
    }

    function testChildConstructorInitializer() public {
        ChildConstructorInitializableMock contract_ = new ChildConstructorInitializableMock();
        assertEq(contract_.initializerRan(), true);
        assertEq(contract_.childInitializerRan(), true);
        assertEq(contract_.onlyInitializingRan(), true);
    }

    function testReinitializationFlow() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        assertEq(contract_.counter(), 0);
        contract_.initialize();
        assertEq(contract_.counter(), 1);
        contract_.reinitialize(2);
        assertEq(contract_.counter(), 2);
        contract_.reinitialize(3);
        assertEq(contract_.counter(), 3);
    }

    function testReinitializationJump() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        contract_.initialize();
        contract_.reinitialize(128);
        assertEq(contract_.counter(), 2);
    }

    function testNestedReinitializerReverts() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.nestedReinitialize(2, 2);
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.nestedReinitialize(2, 3);
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.nestedReinitialize(3, 2);
    }

    function testChainReinitialize() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        contract_.chainReinitialize(2, 3);
        assertEq(contract_.counter(), 2);
    }

    function testGetInitializedVersion() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        contract_.initialize();
        assertEq(contract_.getInitializedVersion(), 1);
        contract_.reinitialize(12);
        assertEq(contract_.getInitializedVersion(), 12);
    }

    function testDisableInitializers() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        contract_.disableInitializers();
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.initialize();
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.reinitialize(255);
    }

    function testDisableAfterInitialization() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        contract_.initialize();
        contract_.disableInitializers();
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        contract_.reinitialize(255);
    }

    function testEvents() public {
        vm.expectEmit(true, false, false, true);
        emit Initialized(1);
        ReinitializerMock contract_ = new ReinitializerMock();
        contract_.initialize();
        vm.expectEmit(true, false, false, true);
        emit Initialized(128);
        contract_.reinitialize(128);
    }

    function testChainedEvents() public {
        ReinitializerMock contract_ = new ReinitializerMock();
        vm.expectEmit(true, false, false, true);
        emit Initialized(2);
        vm.expectEmit(true, false, false, true);
        emit Initialized(3);
        contract_.chainReinitialize(2, 3);
    }

    function testMultipleInheritanceInitialization() public {
        SampleChild contract_ = new SampleChild();
        contract_.initialize(12, "56", 34, 78);
        assertEq(contract_.isHuman(), true);
        assertEq(contract_.mother(), 12);
        assertEq(contract_.gramps(), "56");
        assertEq(contract_.father(), 34);
        assertEq(contract_.child(), 78);
    }

    function testDisableBadSequences() public {
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        new DisableBad1();
        vm.expectRevert(bytes("Initializable: contract is initializing"));
        new DisableBad2();
    }

    function testDisableOkSequence() public {
        DisableOk ok = new DisableOk();
        ok; // silence unused warning
    }
}
