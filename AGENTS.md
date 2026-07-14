<!-- Satellite context file — extends the global hub (~/.claude/CLAUDE.md | ~/.pi/agent/AGENTS.md). Host-neutral; project-specific only. Do not duplicate hub standards here. -->

# SIP Circuits

> Noir ZK circuits for SIP Protocol privacy proofs.

**Ecosystem hub:** See [sip-protocol/sip-protocol/AGENTS.md](https://github.com/sip-protocol/sip-protocol/blob/main/AGENTS.md) for full ecosystem context.

**Status:** M17 Complete | M18 Active. Strategy: same-chain expansion — circuits ready for multi-chain native integration.

## Quick Reference

**Tech Stack:** Noir 1.0.0-beta.15, Barretenberg (UltraHonk), Nargo CLI. 3 circuits, 18 tests passing.

```bash
# Install Nargo
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup

# Development (run from circuit directory)
nargo compile        # Compile circuit
nargo test           # Run tests
nargo info           # Show constraint count
nargo prove          # Generate proof
nargo verify         # Verify proof
```

## Circuits

| Circuit | Purpose | ACIR Opcodes | Tests |
|---------|---------|--------------|-------|
| `funding_proof` | Prove balance >= minimum without revealing balance | 972 | 4 |
| `validity_proof` | Prove intent authorization without revealing sender | 1113 | 6 |
| `fulfillment_proof` | Prove fulfillment correctness with oracle attestation | 1691 | 8 |

**Total: 18 tests passing.**

## Structure

```
circuits/
├── funding_proof/{Nargo.toml, src/main.nr}
├── validity_proof/{Nargo.toml, src/main.nr, target/validity_proof.json ✅}
├── fulfillment_proof/{Nargo.toml, src/main.nr, target/fulfillment_proof.json ✅}
└── README.md
```

## Circuit Details

### Funding Proof
Proves `balance >= minimum_required` without revealing balance. **Public:** `commitment_hash` ([u8;32]), `minimum_required` (u64), `asset_id` (Field). **Private:** `balance` (u64), `blinding` (Field).

### Validity Proof
Proves intent authorized by sender without revealing identity. **Public:** `intent_hash`, `sender_commitment_x/y`, `nullifier`, `timestamp`, `expiry`. **Private:** `sender_address`, `sender_blinding`, `sender_secret`, `pub_key_x/y`, `signature`, `message_hash`, `nonce`.

### Fulfillment Proof
Proves solver correctly executed swap. **Public:** `intent_hash`, `output_commitment_x/y`, `recipient_stealth`, `min_output_amount`, `solver_id`, `fulfillment_time`, `expiry`. **Private:** `output_amount`, `output_blinding`, `solver_secret`, oracle attestation data.

## Same-Chain Considerations (M17)

For Solana same-chain privacy: no cross-chain oracle needed (direct on-chain verification); optimize proof verification cost for Solana compute units; browser proving for mobile wallet UX; Jupiter integration (standard swap interface with privacy proofs).

## Cryptographic Primitives

| Primitive | Usage | Library |
|-----------|-------|---------|
| Pedersen Hash | Commitments, nullifiers | `std::hash::pedersen_hash` |
| BLAKE3 | Commitment binding, message hashing | `std::hash::blake3` |
| ECDSA secp256k1 | Signature verification | `std::ecdsa_secp256k1::verify_signature` |

## Integration with SDK

Compiled JSON artifacts (`target/*.json`) are used by the SDK's `NoirProofProvider`:

```typescript
import { NoirProofProvider } from '@sip-protocol/sdk'
const provider = new NoirProofProvider()
await provider.initialize()
const result = await provider.generateFundingProof({ balance: 100n, minimumRequired: 50n, blindingFactor: new Uint8Array(32), assetId: '0xABCD', /* ... */ })
```

Specs in docs-sip: `/specs/funding-proof/`, `/specs/validity-proof/`, `/specs/fulfillment-proof/`.

## Repo-Specific Guidelines

**DO:** follow Noir best practices; write comprehensive edge-case tests; document public/private inputs clearly; keep constraint counts minimal; consider Solana compute limits for verification.
**DON'T:** expose private inputs in the circuit interface; use external dependencies (stdlib only); skip security-critical assertions.