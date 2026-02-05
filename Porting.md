# Porting Checklist

Source scan: `core_openzeppelin` compared against `src/` for upgradeable counterparts.

Matching rule used for each core file:
- Src match: prefer same relative path with `Upgradeable` suffix (`X.sol` -> `XUpgradeable.sol`).
- OZ-analogue match: same rule, plus Core<->OZ name mapping: `CRC20<->ERC20`, `CRC721<->ERC721`, `CRC1155<->ERC1155`, `EDDSA<->ECDSA`, including `I*` interfaces.

Applied filters:
- Removed contracts that do not have an OZ-upgradeable counterpart.
- Removed all mock contracts (`mocks/*`).

Legend:
- `[x]` counterpart exists in `src/`
- `[ ]` counterpart not found in `src/`

Totals after filters: **53** contracts, **53** ported, **0** missing.

## Tests Checklist

- [x] `utils/introspection/ERC165.sol` tests ported -> `test/utils/introspection/ERC165Upgradeable.t.sol`
- [x] `security/Pausable.sol` tests ported -> `test/security/PausableUpgradeable.t.sol`
- [x] `security/ReentrancyGuard.sol` tests ported -> `test/security/ReentrancyGuardUpgradeable.t.sol`
- [x] `metatx/ERC2771Context.sol` tests ported -> `test/metatx/ERC2771ContextUpgradeable.t.sol`
- [x] `metatx/MinimalForwarder.sol` tests ported -> `test/metatx/MinimalForwarderUpgradeable.t.sol`
- [x] `token/CRC20/CRC20.sol` tests ported -> `test/token/CRC20/CRC20Upgradeable.t.sol`
- [x] `token/CRC20/extensions/CRC20Burnable.sol` tests ported -> `test/token/CRC20/extensions/CRC20BurnableUpgradeable.t.sol`
- [x] `token/CRC20/extensions/CRC20Capped.sol` tests ported -> `test/token/CRC20/extensions/CRC20CappedUpgradeable.t.sol`
- [x] `token/CRC20/extensions/CRC20Pausable.sol` tests ported -> `test/token/CRC20/extensions/CRC20PausableUpgradeable.t.sol`
- [x] `token/CRC20/extensions/CRC20Permit.sol` tests ported -> `test/token/CRC20/extensions/CRC20PermitUpgradeable.t.sol`
- [x] `token/CRC721/CRC721.sol` tests ported -> `test/token/CRC721/CRC721Upgradeable.t.sol`
- [x] `token/CRC721/extensions/CRC721Enumerable.sol` tests ported -> `test/token/CRC721/extensions/CRC721EnumerableUpgradeable.t.sol`

## access (3 ported / 0 missing)

- [x] `access/AccessControl.sol` -> `src/access/AccessControlUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/access/AccessControlUpgradeable.sol`)
- [x] `access/IAccessControl.sol` -> `src/access/IAccessControlUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/access/IAccessControlUpgradeable.sol`)
- [x] `access/Ownable.sol` -> `src/access/OwnableUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/access/OwnableUpgradeable.sol`)

## interfaces (4 ported / 0 missing)

- [x] `interfaces/IERC1271.sol` -> `src/interfaces/IERC1271Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/interfaces/IERC1271Upgradeable.sol`)
- [x] `interfaces/IERC1967.sol` -> `src/interfaces/IERC1967Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/interfaces/IERC1967Upgradeable.sol`)
- [x] `interfaces/IERC5267.sol` -> `src/interfaces/IERC5267Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/interfaces/IERC5267Upgradeable.sol`)
- [x] `interfaces/draft-IERC1822.sol` -> `src/interfaces/draft-IERC1822Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/interfaces/draft-IERC1822Upgradeable.sol`)

## metatx (2 ported / 0 missing)

- [x] `metatx/ERC2771Context.sol` -> `src/metatx/ERC2771ContextUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/metatx/ERC2771ContextUpgradeable.sol`)
- [x] `metatx/MinimalForwarder.sol` -> `src/metatx/MinimalForwarderUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/metatx/MinimalForwarderUpgradeable.sol`)

## proxy (5 ported / 0 missing)

- [x] `proxy/Clones.sol` -> `src/proxy/ClonesUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/proxy/ClonesUpgradeable.sol`)
- [x] `proxy/ERC1967/ERC1967Upgrade.sol` -> `src/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol`)
- [x] `proxy/beacon/IBeacon.sol` -> `src/proxy/beacon/IBeaconUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/proxy/beacon/IBeaconUpgradeable.sol`)
- [x] `proxy/utils/Initializable.sol` -> `src/proxy/utils/Initializable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/proxy/utils/Initializable.sol`)
- [x] `proxy/utils/UUPSUpgradeable.sol` -> `src/proxy/utils/UUPSUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/proxy/utils/UUPSUpgradeable.sol`)

## security (2 ported / 0 missing)

- [x] `security/Pausable.sol` -> `src/security/PausableUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/security/PausableUpgradeable.sol`)
- [x] `security/ReentrancyGuard.sol` -> `src/security/ReentrancyGuardUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/security/ReentrancyGuardUpgradeable.sol`)

## token (14 ported / 0 missing)

- [x] `token/CRC20/CRC20.sol` -> `src/token/CRC20/CRC20Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/ERC20Upgradeable.sol`)
- [x] `token/CRC20/ICRC20.sol` -> `src/token/CRC20/ICRC20Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/IERC20Upgradeable.sol`)
- [x] `token/CRC20/extensions/CRC20Burnable.sol` -> `src/token/CRC20/extensions/CRC20BurnableUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol`)
- [x] `token/CRC20/extensions/CRC20Capped.sol` -> `src/token/CRC20/extensions/CRC20CappedUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol`)
- [x] `token/CRC20/extensions/CRC20Pausable.sol` -> `src/token/CRC20/extensions/CRC20PausableUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol`)
- [x] `token/CRC20/extensions/CRC20Permit.sol` -> `src/token/CRC20/extensions/CRC20PermitUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol`)
- [x] `token/CRC20/extensions/ICRC20Metadata.sol` -> `src/token/CRC20/extensions/ICRC20MetadataUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol`)
- [x] `token/CRC20/extensions/ICRC20Permit.sol` -> `src/token/CRC20/extensions/ICRC20PermitUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol`)
- [x] `token/CRC721/CRC721.sol` -> `src/token/CRC721/CRC721Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC721/ERC721Upgradeable.sol`)
- [x] `token/CRC721/ICRC721.sol` -> `src/token/CRC721/ICRC721Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC721/IERC721Upgradeable.sol`)
- [x] `token/CRC721/ICRC721Receiver.sol` -> `src/token/CRC721/ICRC721ReceiverUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol`)
- [x] `token/CRC721/extensions/CRC721Enumerable.sol` -> `src/token/CRC721/extensions/CRC721EnumerableUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol`)
- [x] `token/CRC721/extensions/ICRC721Enumerable.sol` -> `src/token/CRC721/extensions/ICRC721EnumerableUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol`)
- [x] `token/CRC721/extensions/ICRC721Metadata.sol` -> `src/token/CRC721/extensions/ICRC721MetadataUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol`)

## utils (23 ported / 0 missing)

- [x] `utils/Address.sol` -> `src/utils/AddressUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/AddressUpgradeable.sol`)
- [x] `utils/Arrays.sol` -> `src/utils/ArraysUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/ArraysUpgradeable.sol`)
- [x] `utils/Base64.sol` -> `src/utils/Base64Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/Base64Upgradeable.sol`)
- [x] `utils/Checkpoints.sol` -> `src/utils/CheckpointsUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/CheckpointsUpgradeable.sol`)
- [x] `utils/Context.sol` -> `src/utils/ContextUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/ContextUpgradeable.sol`)
- [x] `utils/Counters.sol` -> `src/utils/CountersUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/CountersUpgradeable.sol`)
- [x] `utils/Create2.sol` -> `src/utils/Create2Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/Create2Upgradeable.sol`)
- [x] `utils/Multicall.sol` -> `src/utils/MulticallUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/MulticallUpgradeable.sol`)
- [x] `utils/StorageSlot.sol` -> `src/utils/StorageSlotUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/StorageSlotUpgradeable.sol`)
- [x] `utils/Strings.sol` -> `src/utils/StringsUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/StringsUpgradeable.sol`)
- [x] `utils/Timers.sol` -> `src/utils/TimersUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/TimersUpgradeable.sol`)
- [x] `utils/cryptography/EDDSA.sol` -> `src/utils/cryptography/EDDSAUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/cryptography/ECDSAUpgradeable.sol`)
- [x] `utils/cryptography/EIP712.sol` -> `src/utils/cryptography/EIP712Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/cryptography/EIP712Upgradeable.sol`)
- [x] `utils/cryptography/MerkleProof.sol` -> `src/utils/cryptography/MerkleProofUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/cryptography/MerkleProofUpgradeable.sol`)
- [x] `utils/cryptography/SignatureChecker.sol` -> `src/utils/cryptography/SignatureCheckerUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol`)
- [x] `utils/cryptography/draft-EIP712.sol` -> `src/utils/cryptography/draft-EIP712Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol`)
- [x] `utils/introspection/ERC165.sol` -> `src/utils/introspection/ERC165Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/introspection/ERC165Upgradeable.sol`)
- [x] `utils/introspection/IERC165.sol` -> `src/utils/introspection/IERC165Upgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/introspection/IERC165Upgradeable.sol`)
- [x] `utils/math/Math.sol` -> `src/utils/math/MathUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/math/MathUpgradeable.sol`)
- [x] `utils/math/SafeCast.sol` -> `src/utils/math/SafeCastUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/math/SafeCastUpgradeable.sol`)
- [x] `utils/math/SignedMath.sol` -> `src/utils/math/SignedMathUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/math/SignedMathUpgradeable.sol`)
- [x] `utils/structs/EnumerableMap.sol` -> `src/utils/structs/EnumerableMapUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/structs/EnumerableMapUpgradeable.sol`)
- [x] `utils/structs/EnumerableSet.sol` -> `src/utils/structs/EnumerableSetUpgradeable.sol` (OZ-upgradeable analogue: `openzeppelin_contracts_upgradeable/utils/structs/EnumerableSetUpgradeable.sol`)
