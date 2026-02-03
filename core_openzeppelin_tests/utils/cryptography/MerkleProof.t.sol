// SPDX-License-Identifier: UNLICENSED
pragma solidity ^1.1.2;

import "spark-std/Test.sol";
import "../../../src/utils/cryptography/MerkleProof.sol";

contract MerkleProofHarness {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) external pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) external pure returns (bool) {
        return MerkleProof.verifyCalldata(proof, root, leaf);
    }

    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) external pure returns (bool) {
        return MerkleProof.multiProofVerify(proof, proofFlags, root, leaves);
    }

    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) external pure returns (bool) {
        return MerkleProof.multiProofVerifyCalldata(proof, proofFlags, root, leaves);
    }
}

contract MerkleProofTest is Test {
    MerkleProofHarness private _proof;

    function setUp() public {
        _proof = new MerkleProofHarness();
    }

    function testVerifyValidProof() public {
        bytes memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        bytes32[] memory leaves = new bytes32[](alphabet.length);
        for (uint256 i = 0; i < alphabet.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(alphabet[i]));
        }

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);
        bytes32 leaf = leaves[0];
        bytes32[] memory proof = _getProof(layers, 0);

        assertTrue(_proof.verify(proof, root, leaf));
        assertTrue(_proof.verifyCalldata(proof, root, leaf));

        bytes32 noSuchLeaf = _hashPair(leaves[0], leaves[1]);
        bytes32[] memory shortProof = _slice(proof, 1);
        assertTrue(_proof.verify(shortProof, root, noSuchLeaf));
        assertTrue(_proof.verifyCalldata(shortProof, root, noSuchLeaf));
    }

    function testVerifyInvalidProof() public {
        bytes32[] memory correctLeaves = new bytes32[](3);
        correctLeaves[0] = keccak256("a");
        correctLeaves[1] = keccak256("b");
        correctLeaves[2] = keccak256("c");

        bytes32[][] memory correctLayers = _buildTree(correctLeaves);
        bytes32 correctRoot = _root(correctLayers);
        bytes32 correctLeaf = correctLeaves[0];

        bytes32[] memory badLeaves = new bytes32[](3);
        badLeaves[0] = keccak256("d");
        badLeaves[1] = keccak256("e");
        badLeaves[2] = keccak256("f");
        bytes32[][] memory badLayers = _buildTree(badLeaves);
        bytes32[] memory badProof = _getProof(badLayers, 0);

        assertFalse(_proof.verify(badProof, correctRoot, correctLeaf));
        assertFalse(_proof.verifyCalldata(badProof, correctRoot, correctLeaf));
    }

    function testVerifyInvalidLengthProof() public {
        bytes32[] memory leaves = new bytes32[](3);
        leaves[0] = keccak256("a");
        leaves[1] = keccak256("b");
        leaves[2] = keccak256("c");

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);
        bytes32 leaf = leaves[0];

        bytes32[] memory proof = _getProof(layers, 0);
        bytes32[] memory badProof = proof.length > 1 ? _slice(proof, proof.length - 1) : new bytes32[](0);

        assertFalse(_proof.verify(badProof, root, leaf));
        assertFalse(_proof.verifyCalldata(badProof, root, leaf));
    }

    function testMultiProofVerifyValid() public {
        bytes32[] memory leaves = new bytes32[](6);
        leaves[0] = keccak256("a");
        leaves[1] = keccak256("b");
        leaves[2] = keccak256("c");
        leaves[3] = keccak256("d");
        leaves[4] = keccak256("e");
        leaves[5] = keccak256("f");
        _sortBytes32(leaves);

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);

        bytes32[] memory proofLeaves = new bytes32[](3);
        proofLeaves[0] = keccak256("b");
        proofLeaves[1] = keccak256("f");
        proofLeaves[2] = keccak256("d");
        _sortBytes32(proofLeaves);

        bool[] memory selected = _selectLeaves(leaves, proofLeaves);
        (bytes32[] memory proof, bool[] memory flags,) = _getMultiProof(layers, selected);

        assertTrue(_proof.multiProofVerify(proof, flags, root, proofLeaves));
        assertTrue(_proof.multiProofVerifyCalldata(proof, flags, root, proofLeaves));
    }

    function testMultiProofVerifyInvalid() public {
        bytes32[] memory leaves = new bytes32[](6);
        leaves[0] = keccak256("a");
        leaves[1] = keccak256("b");
        leaves[2] = keccak256("c");
        leaves[3] = keccak256("d");
        leaves[4] = keccak256("e");
        leaves[5] = keccak256("f");
        _sortBytes32(leaves);

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);

        bytes32[] memory badLeaves = new bytes32[](3);
        badLeaves[0] = keccak256("g");
        badLeaves[1] = keccak256("h");
        badLeaves[2] = keccak256("i");
        _sortBytes32(badLeaves);

        bytes32[][] memory badLayers = _buildTree(badLeaves);
        bool[] memory selected = new bool[](badLeaves.length);
        for (uint256 i = 0; i < selected.length; i++) {
            selected[i] = true;
        }
        (bytes32[] memory badProof, bool[] memory badFlags,) = _getMultiProof(badLayers, selected);

        assertFalse(_proof.multiProofVerify(badProof, badFlags, root, badLeaves));
        assertFalse(_proof.multiProofVerifyCalldata(badProof, badFlags, root, badLeaves));
    }

    function testMultiProofInvalid1() public {
        bytes32[] memory leaves = new bytes32[](4);
        leaves[0] = keccak256("a");
        leaves[1] = keccak256("b");
        leaves[2] = keccak256("c");
        leaves[3] = keccak256("d");
        _sortBytes32(leaves);

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);
        bytes32 fill = bytes32(0);
        bytes32 badLeaf = keccak256("e");

        bytes32[] memory proof = new bytes32[](3);
        proof[0] = leaves[1];
        proof[1] = fill;
        proof[2] = layers[1][1];

        bool[] memory flags = new bool[](3);
        flags[0] = false;
        flags[1] = false;
        flags[2] = false;

        bytes32[] memory proofLeaves = new bytes32[](2);
        proofLeaves[0] = leaves[0];
        proofLeaves[1] = badLeaf;

        vm.expectRevert(bytes("MerkleProof: invalid multiproof"));
        _proof.multiProofVerify(proof, flags, root, proofLeaves);

        vm.expectRevert(bytes("MerkleProof: invalid multiproof"));
        _proof.multiProofVerifyCalldata(proof, flags, root, proofLeaves);
    }

    function testMultiProofInvalid2() public {
        bytes32[] memory leaves = new bytes32[](4);
        leaves[0] = keccak256("a");
        leaves[1] = keccak256("b");
        leaves[2] = keccak256("c");
        leaves[3] = keccak256("d");
        _sortBytes32(leaves);

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);
        bytes32 fill = bytes32(0);
        bytes32 badLeaf = keccak256("e");

        bytes32[] memory proof = new bytes32[](3);
        proof[0] = leaves[1];
        proof[1] = fill;
        proof[2] = layers[1][1];

        bool[] memory flags = new bool[](4);
        flags[0] = false;
        flags[1] = false;
        flags[2] = false;
        flags[3] = false;

        bytes32[] memory proofLeaves = new bytes32[](2);
        proofLeaves[0] = badLeaf;
        proofLeaves[1] = leaves[0];

        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x32));
        _proof.multiProofVerify(proof, flags, root, proofLeaves);

        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x32));
        _proof.multiProofVerifyCalldata(proof, flags, root, proofLeaves);
    }

    function testMultiProofSingleLeaf() public {
        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] = keccak256("a");
        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);

        bool[] memory selected = new bool[](1);
        selected[0] = true;
        (bytes32[] memory proof, bool[] memory flags, bytes32[] memory proofLeaves) = _getMultiProof(layers, selected);

        assertTrue(_proof.multiProofVerify(proof, flags, root, proofLeaves));
        assertTrue(_proof.multiProofVerifyCalldata(proof, flags, root, proofLeaves));
    }

    function testMultiProofEmptyLeaves() public {
        bytes32[] memory leaves = new bytes32[](4);
        leaves[0] = keccak256("a");
        leaves[1] = keccak256("b");
        leaves[2] = keccak256("c");
        leaves[3] = keccak256("d");
        _sortBytes32(leaves);

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);

        bytes32[] memory proof = new bytes32[](1);
        proof[0] = root;
        bool[] memory flags = new bool[](0);
        bytes32[] memory emptyLeaves = new bytes32[](0);

        assertTrue(_proof.multiProofVerify(proof, flags, root, emptyLeaves));
        assertTrue(_proof.multiProofVerifyCalldata(proof, flags, root, emptyLeaves));
    }

    function testMultiProofRevertsOnZeroNode() public {
        bytes32[] memory leaves = new bytes32[](2);
        leaves[0] = keccak256("real leaf");
        leaves[1] = bytes32(0);

        bytes32[][] memory layers = _buildTree(leaves);
        bytes32 root = _root(layers);

        bytes32[] memory maliciousLeaves = new bytes32[](3);
        maliciousLeaves[0] = keccak256("some");
        maliciousLeaves[1] = keccak256("malicious");
        maliciousLeaves[2] = keccak256("leaves");
        _sortBytes32(maliciousLeaves);

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = leaves[0];
        proof[1] = leaves[0];

        bool[] memory flags = new bool[](3);
        flags[0] = true;
        flags[1] = true;
        flags[2] = false;

        vm.expectRevert(bytes("MerkleProof: invalid multiproof"));
        _proof.multiProofVerify(proof, flags, root, maliciousLeaves);

        vm.expectRevert(bytes("MerkleProof: invalid multiproof"));
        _proof.multiProofVerifyCalldata(proof, flags, root, maliciousLeaves);
    }

    function _root(bytes32[][] memory layers) private pure returns (bytes32) {
        return layers[layers.length - 1][0];
    }

    function _buildTree(bytes32[] memory leaves) private pure returns (bytes32[][] memory layers) {
        uint256 depth = 0;
        uint256 n = leaves.length;
        while (n > 1) {
            n = (n + 1) / 2;
            depth++;
        }

        layers = new bytes32[][](depth + 1);
        layers[0] = leaves;

        n = leaves.length;
        for (uint256 level = 0; level < depth; level++) {
            uint256 nextLen = (n + 1) / 2;
            bytes32[] memory nextLayer = new bytes32[](nextLen);
            for (uint256 i = 0; i < nextLen; i++) {
                uint256 left = i * 2;
                uint256 right = left + 1;
                if (right < n) {
                    nextLayer[i] = _hashPair(layers[level][left], layers[level][right]);
                } else {
                    nextLayer[i] = layers[level][left];
                }
            }
            layers[level + 1] = nextLayer;
            n = nextLen;
        }
    }

    function _getProof(bytes32[][] memory layers, uint256 index) private pure returns (bytes32[] memory proof) {
        uint256 depth = layers.length;
        bytes32[] memory temp = new bytes32[](depth - 1);
        uint256 proofLen = 0;

        for (uint256 level = 0; level < depth - 1; level++) {
            uint256 layerLen = layers[level].length;
            if (index % 2 == 0) {
                if (index + 1 < layerLen) {
                    temp[proofLen++] = layers[level][index + 1];
                }
            } else {
                temp[proofLen++] = layers[level][index - 1];
            }
            index = index / 2;
        }

        proof = new bytes32[](proofLen);
        for (uint256 i = 0; i < proofLen; i++) {
            proof[i] = temp[i];
        }
    }

    function _getMultiProof(
        bytes32[][] memory layers,
        bool[] memory selectedLeaves
    ) private pure returns (bytes32[] memory proof, bool[] memory flags, bytes32[] memory proofLeaves) {
        proofLeaves = _collectSelectedLeaves(layers[0], selectedLeaves);
        (proof, flags) = _buildProofAndFlags(layers, selectedLeaves);
    }

    function _collectSelectedLeaves(
        bytes32[] memory leaves,
        bool[] memory selectedLeaves
    ) private pure returns (bytes32[] memory proofLeaves) {
        uint256 count = 0;
        for (uint256 i = 0; i < leaves.length; i++) {
            if (selectedLeaves[i]) {
                count++;
            }
        }

        proofLeaves = new bytes32[](count);
        uint256 pos = 0;
        for (uint256 i = 0; i < leaves.length; i++) {
            if (selectedLeaves[i]) {
                proofLeaves[pos++] = leaves[i];
            }
        }
    }

    function _buildProofAndFlags(
        bytes32[][] memory layers,
        bool[] memory selectedLeaves
    ) private pure returns (bytes32[] memory proof, bool[] memory flags) {
        uint256 leavesLen = layers[0].length;
        bytes32[] memory proofTemp = new bytes32[](leavesLen * 2);
        bool[] memory flagsTemp = new bool[](leavesLen * 2);
        uint256 proofLen = 0;
        uint256 flagLen = 0;

        bool[] memory selected = selectedLeaves;
        for (uint256 level = 0; level < layers.length - 1; level++) {
            (selected, proofLen, flagLen) = _processLevel(
                layers[level],
                selected,
                proofTemp,
                flagsTemp,
                proofLen,
                flagLen
            );
        }

        proof = _trimBytes32(proofTemp, proofLen);
        flags = _trimBools(flagsTemp, flagLen);
    }

    function _processLevel(
        bytes32[] memory layer,
        bool[] memory selected,
        bytes32[] memory proofTemp,
        bool[] memory flagsTemp,
        uint256 proofLen,
        uint256 flagLen
    ) private pure returns (bool[] memory nextSelected, uint256 outProofLen, uint256 outFlagLen) {
        uint256 layerLen = layer.length;
        uint256 nextLen = (layerLen + 1) / 2;
        nextSelected = new bool[](nextLen);

        for (uint256 i = 0; i < layerLen; i += 2) {
            bool leftSel = selected[i];
            bool rightSel = i + 1 < layerLen ? selected[i + 1] : false;
            if (leftSel || rightSel) {
                nextSelected[i / 2] = true;
                if (i + 1 < layerLen) {
                    if (leftSel && rightSel) {
                        flagsTemp[flagLen++] = true;
                    } else {
                        flagsTemp[flagLen++] = false;
                        bytes32 sibling = leftSel ? layer[i + 1] : layer[i];
                        proofTemp[proofLen++] = sibling;
                    }
                }
            }
        }

        outProofLen = proofLen;
        outFlagLen = flagLen;
    }

    function _trimBytes32(bytes32[] memory values, uint256 len) private pure returns (bytes32[] memory out) {
        out = new bytes32[](len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = values[i];
        }
    }

    function _trimBools(bool[] memory values, uint256 len) private pure returns (bool[] memory out) {
        out = new bool[](len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = values[i];
        }
    }

    function _selectLeaves(bytes32[] memory leaves, bytes32[] memory proofLeaves) private pure returns (bool[] memory) {
        bool[] memory selected = new bool[](leaves.length);
        for (uint256 i = 0; i < leaves.length; i++) {
            for (uint256 j = 0; j < proofLeaves.length; j++) {
                if (leaves[i] == proofLeaves[j]) {
                    selected[i] = true;
                    break;
                }
            }
        }
        return selected;
    }

    function _sortBytes32(bytes32[] memory values) private pure {
        for (uint256 i = 1; i < values.length; i++) {
            bytes32 key = values[i];
            uint256 j = i;
            while (j > 0 && values[j - 1] > key) {
                values[j] = values[j - 1];
                j--;
            }
            values[j] = key;
        }
    }

    function _slice(bytes32[] memory values, uint256 skip) private pure returns (bytes32[] memory out) {
        if (skip >= values.length) {
            return new bytes32[](0);
        }
        uint256 len = values.length - skip;
        out = new bytes32[](len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = values[i + skip];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}
