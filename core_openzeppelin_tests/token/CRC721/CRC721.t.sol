// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/token/CRC721/CRC721.sol";
import "../../../src/token/CRC721/ICRC721Receiver.sol";
import "../../../src/utils/Checksum.sol";

contract CRC721Mock is CRC721 {
    constructor(string memory name_, string memory symbol_) CRC721(name_, symbol_) {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId, "");
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return "https://api.example.com/v1/";
    }
}

contract CRC721ReceiverMock is ICRC721Receiver {
    event Received(address operator, address from, uint256 tokenId, bytes data);

    bytes4 private _retval;
    bool private _revertWithReason;
    bool private _revertWithoutReason;

    constructor(bytes4 retval, bool revertWithReason, bool revertWithoutReason) {
        _retval = retval;
        _revertWithReason = revertWithReason;
        _revertWithoutReason = revertWithoutReason;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
        if (_revertWithReason) {
            revert("CRC721ReceiverMock: reverting");
        }
        if (_revertWithoutReason) {
            revert();
        }
        emit Received(operator, from, tokenId, data);
        return _retval;
    }
}

contract NonCRC721ReceiverMock {}

contract CRC721Test is Test {
    event Received(address operator, address from, uint256 tokenId, bytes data);
    CRC721Mock private _token;

    address private _owner;
    address private _approved;
    address private _operator;
    address private _other;

    uint256 private constant _FIRST_TOKEN = 5042;
    uint256 private constant _SECOND_TOKEN = 79217;
    uint256 private constant _NON_EXISTENT = 13;

    function setUp() public {
        _owner = address(0x1111);
        _approved = address(0x2222);
        _operator = address(0x3333);
        _other = address(0x4444);

        _token = new CRC721Mock("Non Fungible Token", "NFT");
        _token.mint(_owner, _FIRST_TOKEN);
        _token.mint(_owner, _SECOND_TOKEN);
    }

    function testSupportsInterfaceIds() public {
        bytes4 erc165Id = _selector("supportsInterface(bytes4)");
        bytes4 erc721Id = _interfaceIdERC721();
        bytes4 erc721MetadataId = _interfaceIdERC721Metadata();

        assertEq(erc165Id, bytes4(0x80ada41b));
        assertTrue(_token.supportsInterface(erc165Id));
        assertTrue(_token.supportsInterface(erc721Id));
        assertTrue(_token.supportsInterface(erc721MetadataId));
        assertFalse(_token.supportsInterface(0xffffffff));
    }

    function testBalanceOfOwner() public {
        assertEq(_token.balanceOf(_owner), 2);
    }

    function testBalanceOfZeroReverts() public {
        vm.expectRevert(bytes("CRC721: address zero is not a valid owner"));
        _token.balanceOf(address(0));
    }

    function testBalanceOfChecksumZeroReverts() public {
        vm.expectRevert(bytes("CRC721: address zero is not a valid owner"));
        _token.balanceOf(Checksum.zeroAddress());
    }

    function testOwnerOf() public {
        assertEq(_token.ownerOf(_FIRST_TOKEN), _owner);
    }

    function testOwnerOfInvalidReverts() public {
        vm.expectRevert(bytes("CRC721: invalid token ID"));
        _token.ownerOf(_NON_EXISTENT);
    }

    function testTokenURI() public {
        string memory expected = "https://api.example.com/v1/5042";
        assertEq(_token.tokenURI(_FIRST_TOKEN), expected);
    }

    function testApproveAndGetApproved() public {
        vm.prank(_owner);
        _token.approve(_approved, _FIRST_TOKEN);
        assertEq(_token.getApproved(_FIRST_TOKEN), _approved);
    }

    function testSetApprovalForAll() public {
        vm.prank(_owner);
        _token.setApprovalForAll(_operator, true);
        assertTrue(_token.isApprovedForAll(_owner, _operator));
    }

    function testTransferFromByOwner() public {
        vm.prank(_owner);
        _token.transferFrom(_owner, _other, _FIRST_TOKEN);

        assertEq(_token.ownerOf(_FIRST_TOKEN), _other);
        assertEq(_token.balanceOf(_owner), 1);
        assertEq(_token.balanceOf(_other), 1);
    }

    function testTransferFromByApproved() public {
        vm.prank(_owner);
        _token.approve(_approved, _FIRST_TOKEN);

        vm.prank(_approved);
        _token.transferFrom(_owner, _other, _FIRST_TOKEN);

        assertEq(_token.ownerOf(_FIRST_TOKEN), _other);
    }

    function testTransferToChecksumZeroReverts() public {
        vm.prank(_owner);
        vm.expectRevert(bytes("CRC721: transfer to the zero address"));
        _token.transferFrom(_owner, Checksum.zeroAddress(), _FIRST_TOKEN);
    }

    function testMintToChecksumZeroReverts() public {
        CRC721Mock token = new CRC721Mock("Non Fungible Token", "NFT");
        vm.expectRevert(bytes("CRC721: mint to the zero address"));
        token.mint(Checksum.zeroAddress(), 1);
    }

    function testSafeTransferToReceiver() public {
        bytes4 magic = _selector("onERC721Received(address,address,uint256,bytes)");
        CRC721ReceiverMock receiver = new CRC721ReceiverMock(magic, false, false);

        vm.prank(_owner);
        vm.expectEmit(true, true, true, true);
        emit Received(_owner, _owner, _FIRST_TOKEN, "");
        _token.safeTransferFrom(_owner, address(receiver), _FIRST_TOKEN);
    }

    function testSafeTransferToNonReceiverReverts() public {
        NonCRC721ReceiverMock nonReceiver = new NonCRC721ReceiverMock();
        vm.prank(_owner);
        vm.expectRevert(bytes("CRC721: transfer to non CRC721Receiver implementer"));
        _token.safeTransferFrom(_owner, address(nonReceiver), _FIRST_TOKEN);
    }

    function _selector(string memory sig) private pure returns (bytes4) {
        return bytes4(keccak256(bytes(sig)));
    }

    function _interfaceIdERC721() private pure returns (bytes4) {
        bytes4[] memory selectors = new bytes4[](9);
        selectors[0] = _selector("balanceOf(address)");
        selectors[1] = _selector("ownerOf(uint256)");
        selectors[2] = _selector("approve(address,uint256)");
        selectors[3] = _selector("getApproved(uint256)");
        selectors[4] = _selector("setApprovalForAll(address,bool)");
        selectors[5] = _selector("isApprovedForAll(address,address)");
        selectors[6] = _selector("transferFrom(address,address,uint256)");
        selectors[7] = _selector("safeTransferFrom(address,address,uint256)");
        selectors[8] = _selector("safeTransferFrom(address,address,uint256,bytes)");
        return _xorSelectors(selectors);
    }

    function _interfaceIdERC721Metadata() private pure returns (bytes4) {
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = _selector("name()");
        selectors[1] = _selector("symbol()");
        selectors[2] = _selector("tokenURI(uint256)");
        return _xorSelectors(selectors);
    }

    function _xorSelectors(bytes4[] memory selectors) private pure returns (bytes4 id) {
        for (uint256 i = 0; i < selectors.length; i++) {
            id ^= selectors[i];
        }
    }
}
