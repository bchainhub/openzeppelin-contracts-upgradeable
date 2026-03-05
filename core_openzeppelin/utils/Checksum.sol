// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^1.1.0;

library Checksum {
    function zeroAddress() internal view returns (address) {
        uint8 chainId = _getChainId();

        if (chainId == 1) {
            return address(0xcb540000000000000000000000000000000000000000);
        } else if (chainId == 3) {
            return address(0xab720000000000000000000000000000000000000000);
        } else {
            return address(0xce450000000000000000000000000000000000000000);
        }
    }

    function isValid(address addr) internal pure returns (bool) {
        uint176 a = uint176(addr);

        uint8 prefix = uint8(a >> 168);
        uint8 checkBcd = uint8(a >> 160);
        uint160 raw = uint160(a);

        if ((checkBcd & 0x0f) > 9 || (checkBcd >> 4) > 9) return false;

        uint176 v = (uint176(raw) << 16) | (uint176(prefix) << 8) | uint176(checkBcd);

        return _mod97_hexNibblesAsDecimalDigits(v) == 1;
    }

    function toIcan(uint160 rawAddress) internal view returns (address) {
        uint8 prefix = _getChainPrefix();

        uint176 payload = (uint176(rawAddress) << 16) | (uint176(prefix) << 8);

        uint8 remainder = _mod97_hexNibblesAsDecimalDigits(payload);
        uint8 check = uint8(98 - remainder);

        uint8 checkBcd = _toBcd2(check);

        uint176 out = (uint176(prefix) << 168)
            | (uint176(checkBcd) << 160)
            | uint176(rawAddress);

        return address(out);
    }

    function _mod97_hexNibblesAsDecimalDigits(uint176 v) private pure returns (uint8) {
        uint256 r = 0;

        for (uint256 i = 0; i < 44; ++i) {
            uint256 shift = 4 * (43 - i);
            uint8 t = uint8(v >> shift) & 0x0f;

            if (t < 10) {
                r = (r * 10 + t) % 97;
            } else {
                r = (r * 100 + t) % 97;
            }
        }

        return uint8(r);
    }

    function _toBcd2(uint8 x) private pure returns (uint8) {
        return uint8((x / 10) << 4) | uint8(x % 10);
    }

    function _getChainId() private view returns (uint8) {
        return uint8(block.chainid);
    }

    function _getChainPrefix() private view returns (uint8) {
        uint8 chainId = _getChainId();
        if (chainId == 1) {
            return 203;
        } else if (chainId == 3) {
            return 171;
        } else {
            return 206;
        }
    }
}