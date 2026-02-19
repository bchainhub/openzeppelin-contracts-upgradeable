// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../../src/token/CRC721/extensions/CRC721EnumerableUpgradeable.sol";

contract CRC721EnumerableUpgradeableMock is CRC721EnumerableUpgradeable {
    function initialize(string memory name_, string memory symbol_) external initializer {
        __CRC721_init(name_, symbol_);
        __CRC721Enumerable_init();
    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}

contract CRC721EnumerableUpgradeableTest is Test {
    CRC721EnumerableUpgradeableMock private _token;

    address private _owner;
    address private _newOwner;

    uint256 private constant _FIRST_TOKEN = 5042;
    uint256 private constant _SECOND_TOKEN = 79217;

    function setUp() public {
        _owner = makeAddr("owner");
        _newOwner = makeAddr("newOwner");

        _token = new CRC721EnumerableUpgradeableMock();
        _token.initialize("Non Fungible Token", "NFT");
        _token.mint(_owner, _FIRST_TOKEN);
        _token.mint(_owner, _SECOND_TOKEN);
    }

    function testSupportsInterfaceIds() public {
        bytes4 erc165Id = _selector("supportsInterface(bytes4)");
        bytes4 erc721Id = _interfaceIdERC721();
        bytes4 erc721MetadataId = _interfaceIdERC721Metadata();
        bytes4 erc721EnumerableId = _interfaceIdERC721Enumerable();

        assertEq(erc165Id, bytes4(0x80ada41b));
        assertTrue(_token.supportsInterface(erc165Id));
        assertTrue(_token.supportsInterface(erc721Id));
        assertTrue(_token.supportsInterface(erc721MetadataId));
        assertTrue(_token.supportsInterface(erc721EnumerableId));
    }

    function testTotalSupply() public {
        assertEq(_token.totalSupply(), 2);
    }

    function testTokenOfOwnerByIndex() public {
        assertEq(_token.tokenOfOwnerByIndex(_owner, 0), _FIRST_TOKEN);
    }

    function testTokenOfOwnerByIndexOutOfBoundsReverts() public {
        vm.expectRevert(bytes("CRC721Enumerable: owner index out of bounds"));
        _token.tokenOfOwnerByIndex(_owner, 2);
    }

    function testTokenByIndexOutOfBoundsReverts() public {
        vm.expectRevert(bytes("CRC721Enumerable: global index out of bounds"));
        _token.tokenByIndex(2);
    }

    function testBurnRemovesFromEnumeration() public {
        _token.burn(_FIRST_TOKEN);
        assertEq(_token.totalSupply(), 1);
        assertEq(_token.tokenByIndex(0), _SECOND_TOKEN);
        assertEq(_token.tokenOfOwnerByIndex(_owner, 0), _SECOND_TOKEN);
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

    function _interfaceIdERC721Enumerable() private pure returns (bytes4) {
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = _selector("totalSupply()");
        selectors[1] = _selector("tokenOfOwnerByIndex(address,uint256)");
        selectors[2] = _selector("tokenByIndex(uint256)");
        return _xorSelectors(selectors);
    }

    function _xorSelectors(bytes4[] memory selectors) private pure returns (bytes4 id) {
        for (uint256 i = 0; i < selectors.length; i++) {
            id ^= selectors[i];
        }
    }
}
