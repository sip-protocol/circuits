# CLAUDE.md - SIP Circuits

> **Ecosystem Hub:** See [sip-protocol/CLAUDE.md](https://github.com/sip-protocol/sip-protocol/blob/main/CLAUDE.md) for full ecosystem context

**Repository:** https://github.com/sip-protocol/circuits
**Purpose:** Noir ZK circuits for SIP Protocol privacy proofs

---

## Quick Reference

**Tech Stack:** Noir 1.0.0-beta.15, Barretenberg (UltraHonk), Nargo CLI
**Status:** Implemented - 3 circuits, 19 tests passing

**Key Commands:**
```bash
# Install Nargo
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup

# Development (run from circuit directory)
nargo compile             # Compile circuit
nargo test                # Run tests
nargo info                # Show constraint count
nargo prove               # Generate proof
nargo verify              # Verify proof
```

---

## Circuits

| Circuit | Purpose | ACIR Opcodes | Tests |
|---------|---------|--------------|-------|
| funding_proof | Prove balance >= minimum without revealing balance | 972 | 5 |
| validity_proof | Prove intent authorization without revealing sender | 1113 | 6 |
| fulfillment_proof | Prove fulfillment correctness with oracle attestation | 1691 | 8 |

**Total: 19 tests passing**

---

## Structure

```
circuits/
├── funding_proof/
│   ├── Nargo.toml
│   ├── src/main.nr
│   └── target/funding_proof.json
├── validity_proof/
│   ├── Nargo.toml
│   ├── src/main.nr
│   └── target/validity_proof.json
├── fulfillment_proof/
│   ├── Nargo.toml
│   ├── src/main.nr
│   └── target/fulfillment_proof.json
├── README.md
└── CLAUDE.md
```

---

## Circuit Details

### Funding Proof
Proves: `balance >= minimum_required` without revealing actual balance

**Public Inputs:**
- `commitment_hash: [u8; 32]` - Hash of Pedersen commitment
- `minimum_required: u64` - Minimum balance required
- `asset_id: Field` - Asset identifier

**Private Inputs:**
- `balance: u64` - Actual user balance
- `blinding: Field` - Commitment blinding factor

### Validity Proof
Proves: Intent authorized by sender without revealing identity

**Public Inputs:**
- `intent_hash: Field` - Hash of intent
- `sender_commitment_x/y: Field` - Sender commitment coordinates
- `nullifier: Field` - Prevents double-spending
- `timestamp: u64` - Current time
- `expiry: u64` - Intent expiry

**Private Inputs:**
- `sender_address: Field` - Actual sender
- `sender_blinding: Field` - Commitment blinding
- `sender_secret: Field` - For nullifier derivation
- `pub_key_x/y: [u8; 32]` - ECDSA public key
- `signature: [u8; 64]` - ECDSA signature
- `message_hash: [u8; 32]` - Signed message
- `nonce: Field` - Unique nonce

### Fulfillment Proof
Proves: Solver correctly executed swap

**Public Inputs:**
- `intent_hash: Field` - Intent being fulfilled
- `output_commitment_x/y: Field` - Output commitment
- `recipient_stealth: Field` - Delivery address
- `min_output_amount: u64` - Required minimum
- `solver_id: Field` - Solver identifier
- `fulfillment_time: u64` - When fulfilled
- `expiry: u64` - Intent expiry

**Private Inputs:**
- `output_amount: u64` - Actual delivered amount
- `output_blinding: Field` - Commitment blinding
- `solver_secret: Field` - Derives solver_id
- Oracle attestation data (recipient, amount, tx_hash, block, signature)

---

## Specifications

Detailed specs in docs-sip:
- [Funding Proof Spec](https://docs.sip-protocol.org/specs/funding-proof/)
- [Validity Proof Spec](https://docs.sip-protocol.org/specs/validity-proof/)
- [Fulfillment Proof Spec](https://docs.sip-protocol.org/specs/fulfillment-proof/)

---

## Cryptographic Primitives

| Primitive | Usage | Library |
|-----------|-------|---------|
| Pedersen Hash | Commitments, nullifiers | `std::hash::pedersen_hash` |
| BLAKE3 | Commitment binding, message hashing | `std::hash::blake3` |
| ECDSA secp256k1 | Signature verification | `std::ecdsa_secp256k1::verify_signature` |

---

## Repo-Specific Guidelines

**DO:**
- Follow Noir best practices
- Write comprehensive tests for edge cases
- Document public/private inputs clearly
- Keep constraint counts minimal

**DON'T:**
- Expose private inputs in circuit interface
- Use external dependencies (stdlib only)
- Skip security-critical assertions

---

## Integration with SDK

The compiled JSON artifacts (`target/*.json`) are used by the SDK's `NoirProofProvider`:

```typescript
import { NoirProofProvider } from '@sip-protocol/sdk'

const provider = new NoirProofProvider()
await provider.initialize()

const result = await provider.generateFundingProof({
  balance: 100n,
  minimumRequired: 50n,
  blindingFactor: new Uint8Array(32),
  assetId: '0xABCD',
  // ...
})
```

---

## Related

- [Noir Documentation](https://noir-lang.org/docs)
- [Barretenberg](https://github.com/AztecProtocol/barretenberg)
- [SIP SDK](https://github.com/sip-protocol/sip-protocol)

---

**Last Updated:** 2025-12-02
