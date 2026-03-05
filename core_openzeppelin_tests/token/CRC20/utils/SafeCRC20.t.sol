// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC20/CRC20.sol";
import "../../../../src/token/CRC20/extensions/CRC20Permit.sol";
import "../../../../src/token/CRC20/extensions/ICRC20Permit.sol";
import "../../../../src/token/CRC20/utils/SafeCRC20.sol";
import "../../../../src/utils/cryptography/EDDSA.sol";

contract SafeCRC20Mock {
    using SafeCRC20 for ICRC20;

    function safeTransfer(address token, address to, uint256 value) external {
        ICRC20(token).safeTransfer(to, value);
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) external {
        ICRC20(token).safeTransferFrom(from, to, value);
    }

    function safeApprove(address token, address spender, uint256 value) external {
        ICRC20(token).safeApprove(spender, value);
    }

    function safeIncreaseAllowance(address token, address spender, uint256 value) external {
        ICRC20(token).safeIncreaseAllowance(spender, value);
    }

    function safeDecreaseAllowance(address token, address spender, uint256 value) external {
        ICRC20(token).safeDecreaseAllowance(spender, value);
    }

    function forceApprove(address token, address spender, uint256 value) external {
        ICRC20(token).forceApprove(spender, value);
    }

    function safePermit(
        address token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) external {
        SafeCRC20.safePermit(ICRC20Permit(token), owner, spender, value, deadline, signature);
    }
}

contract CRC20Mock is CRC20 {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setAllowance(address owner, address spender, uint256 amount) external {
        _approve(owner, spender, amount);
    }
}

contract CRC20ReturnFalseMock is CRC20 {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) {}

    function transfer(address, uint256) public pure override returns (bool) {
        return false;
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        return false;
    }

    function approve(address, uint256) public pure override returns (bool) {
        return false;
    }
}

contract CRC20NoReturnMock is CRC20 {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setAllowance(address owner, address spender, uint256 amount) external {
        _approve(owner, spender, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        super.transfer(to, amount);
        assembly {
            return(0, 0)
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        super.transferFrom(from, to, amount);
        assembly {
            return(0, 0)
        }
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        super.approve(spender, amount);
        assembly {
            return(0, 0)
        }
    }
}

contract CRC20ForceApproveMock is CRC20 {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) {}

    function setAllowance(address owner, address spender, uint256 amount) external {
        _approve(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(amount == 0 || allowance(msg.sender, spender) == 0, "USDT approval failure");
        return super.approve(spender, amount);
    }
}

contract CRC20PermitNoRevertMock is CRC20Permit {
    constructor(string memory name_, string memory symbol_) CRC20(name_, symbol_) CRC20Permit(name_) {}

    function permitThatMayRevert(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) public {
        super.permit(owner, spender, value, deadline, signature);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) public override {
        try this.permitThatMayRevert(owner, spender, value, deadline, signature) {
            // do nothing
        } catch {
            // do nothing
        }
    }
}

contract SafeCRC20Test is Test {
    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    string private constant _NAME = "ERC20Mock";
    string private constant _SYMBOL = "ERC20Mock";
    string private constant _VERSION = "1";

    SafeCRC20Mock private _safe;
    address private _receiver;
    address private _spender;
    address private _hasNoCode;

    function setUp() public {
        _safe = new SafeCRC20Mock();
        _receiver = makeAddr("receiver");
        _spender = makeAddr("spender");
        _hasNoCode = makeAddr("hasNoCode");
    }

    function testWithAddressThatHasNoCode() public {
        vm.expectRevert(bytes("Address: call to non-contract"));
        _safe.safeTransfer(_hasNoCode, _receiver, 0);

        vm.expectRevert(bytes("Address: call to non-contract"));
        _safe.safeTransferFrom(_hasNoCode, address(_safe), _receiver, 0);

        vm.expectRevert(bytes("Address: call to non-contract"));
        _safe.safeApprove(_hasNoCode, _spender, 0);

        vm.expectRevert();
        _safe.safeIncreaseAllowance(_hasNoCode, _spender, 0);

        vm.expectRevert();
        _safe.safeDecreaseAllowance(_hasNoCode, _spender, 0);

        vm.expectRevert(bytes("Address: call to non-contract"));
        _safe.forceApprove(_hasNoCode, _spender, 0);
    }

    function testWithTokenThatReturnsFalseOnAllCalls() public {
        CRC20ReturnFalseMock token = new CRC20ReturnFalseMock(_NAME, _SYMBOL);

        vm.expectRevert(bytes("SafeCRC20: CRC20 operation did not succeed"));
        _safe.safeTransfer(address(token), _receiver, 0);

        vm.expectRevert(bytes("SafeCRC20: CRC20 operation did not succeed"));
        _safe.safeTransferFrom(address(token), address(_safe), _receiver, 0);

        vm.expectRevert(bytes("SafeCRC20: CRC20 operation did not succeed"));
        _safe.safeApprove(address(token), _spender, 0);

        vm.expectRevert(bytes("SafeCRC20: CRC20 operation did not succeed"));
        _safe.safeIncreaseAllowance(address(token), _spender, 0);

        vm.expectRevert(bytes("SafeCRC20: CRC20 operation did not succeed"));
        _safe.safeDecreaseAllowance(address(token), _spender, 0);

        vm.expectRevert(bytes("SafeCRC20: CRC20 operation did not succeed"));
        _safe.forceApprove(address(token), _spender, 0);
    }

    function testWithTokenThatReturnsTrueOnAllCalls() public {
        CRC20Mock token = new CRC20Mock(_NAME, _SYMBOL);
        _assertOnlyRevertsOnErrors(token);
    }

    function testWithTokenThatReturnsNoBooleanValues() public {
        CRC20NoReturnMock token = new CRC20NoReturnMock(_NAME, _SYMBOL);
        _assertOnlyRevertsOnErrors(token);
    }

    function testWithTokenThatDoesNotRevertOnInvalidPermit() public {
        CRC20PermitNoRevertMock token = new CRC20PermitNoRevertMock(_NAME, _SYMBOL);
        (address owner, string memory ownerKey) = makeAddrAndKey("permitOwner");
        address permitSpender = _spender;

        bytes memory sig = vm.sign(
            ownerKey,
            _permitDigest(address(token), owner, permitSpender, 42, token.nonces(owner), type(uint256).max)
        );

        assertEq(token.nonces(owner), 0);
        assertEq(token.allowance(owner, permitSpender), 0);
        _safe.safePermit(address(token), owner, permitSpender, 42, type(uint256).max, sig);
        assertEq(token.nonces(owner), 1);
        assertEq(token.allowance(owner, permitSpender), 42);

        // Invalid direct permit call doesn't revert for this token implementation.
        token.permit(owner, permitSpender, 42, type(uint256).max, sig);
        assertEq(token.nonces(owner), 1);

        vm.expectRevert(bytes("SafeCRC20: permit did not succeed"));
        _safe.safePermit(address(token), owner, permitSpender, 42, type(uint256).max, sig);
    }

    function testWithUsdtApprovalBehavior() public {
        CRC20ForceApproveMock token = new CRC20ForceApproveMock(_NAME, _SYMBOL);
        token.setAllowance(address(_safe), _spender, 100);

        vm.expectRevert(bytes("SafeCRC20: approve from non-zero to non-zero allowance"));
        _safe.safeApprove(address(token), _spender, 200);

        _safe.safeApprove(address(token), _spender, 0);
        token.setAllowance(address(_safe), _spender, 100);

        vm.expectRevert(bytes("USDT approval failure"));
        _safe.safeIncreaseAllowance(address(token), _spender, 10);

        vm.expectRevert(bytes("USDT approval failure"));
        _safe.safeDecreaseAllowance(address(token), _spender, 10);

        _safe.forceApprove(address(token), _spender, 200);
        assertEq(token.allowance(address(_safe), _spender), 200);
    }

    function _assertOnlyRevertsOnErrors(CRC20Mock token) private {
        _assertTransfers(token);
        _assertApprovals(token);
    }

    function _assertOnlyRevertsOnErrors(CRC20NoReturnMock token) private {
        _assertTransfers(token);
        _assertApprovals(token);
    }

    function _assertTransfers(CRC20 token) private {
        address owner = makeAddr("owner");
        _mintForTest(address(token), owner, 100);
        _mintForTest(address(token), address(_safe), 100);

        _setAllowance(address(token), owner, address(_safe), type(uint256).max);

        _safe.safeTransfer(address(token), _receiver, 10);
        assertEq(token.balanceOf(_receiver), 10);
        assertEq(token.balanceOf(address(_safe)), 90);

        _safe.safeTransferFrom(address(token), owner, _receiver, 10);
        assertEq(token.balanceOf(_receiver), 20);
        assertEq(token.balanceOf(owner), 90);
    }

    function _assertApprovals(CRC20Mock token) private {
        _assertApprovalFlows(address(token));
    }

    function _assertApprovals(CRC20NoReturnMock token) private {
        _assertApprovalFlows(address(token));
    }

    function _assertApprovalFlows(address token) private {
        // with zero allowance
        _setAllowance(token, address(_safe), _spender, 0);

        _safe.safeApprove(token, _spender, 100);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 100);

        _safe.safeApprove(token, _spender, 0);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 0);

        _safe.forceApprove(token, _spender, 100);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 100);

        _safe.forceApprove(token, _spender, 0);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 0);

        _safe.safeIncreaseAllowance(token, _spender, 10);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 10);

        vm.expectRevert(bytes("SafeCRC20: decreased allowance below zero"));
        _safe.safeDecreaseAllowance(token, _spender, 20);

        // with non-zero allowance
        _setAllowance(token, address(_safe), _spender, 100);

        vm.expectRevert(bytes("SafeCRC20: approve from non-zero to non-zero allowance"));
        _safe.safeApprove(token, _spender, 20);

        _safe.safeApprove(token, _spender, 0);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 0);
        _setAllowance(token, address(_safe), _spender, 100);

        _safe.forceApprove(token, _spender, 20);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 20);
        _setAllowance(token, address(_safe), _spender, 100);

        _safe.forceApprove(token, _spender, 0);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 0);
        _setAllowance(token, address(_safe), _spender, 100);

        _safe.safeIncreaseAllowance(token, _spender, 10);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 110);
        _setAllowance(token, address(_safe), _spender, 100);

        _safe.safeDecreaseAllowance(token, _spender, 50);
        assertEq(ICRC20(token).allowance(address(_safe), _spender), 50);
        _setAllowance(token, address(_safe), _spender, 100);

        vm.expectRevert(bytes("SafeCRC20: decreased allowance below zero"));
        _safe.safeDecreaseAllowance(token, _spender, 200);
    }

    function _setAllowance(address token, address owner, address spender, uint256 value) private {
        (bool ok, ) = token.call(abi.encodeWithSelector(CRC20Mock.setAllowance.selector, owner, spender, value));
        require(ok, "setAllowance failed");
    }

    function _mintForTest(address token, address to, uint256 value) private {
        (bool ok, ) = token.call(abi.encodeWithSelector(CRC20Mock.mint.selector, to, value));
        require(ok, "mint failed");
    }

    function _domainSeparator(address verifyingContract) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes(_NAME)),
                    keccak256(bytes(_VERSION)),
                    block.chainid,
                    verifyingContract
                )
            );
    }

    function _permitDigest(
        address token,
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) private view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        return EDDSA.toTypedDataHash(_domainSeparator(token), structHash);
    }
}
