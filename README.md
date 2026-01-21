# circuits

> Noir ZK Circuits for SIP Protocol

**🏆 Winner — [Zypherpunk Hackathon](https://zypherpunk.xyz) NEAR Track ($4,000)**

---

## Overview

Zero-knowledge proof circuits for the **SIP Protocol** (Shielded Intents Protocol).

## Tech Stack

- **Language:** [Noir](https://noir-lang.org/) 1.0.0-beta.15
- **Backend:** Barretenberg (UltraHonk)
- **Tooling:** Nargo CLI

## Circuits

| Circuit | Purpose | ACIR Opcodes | Tests |
|---------|---------|--------------|-------|
| **funding_proof** | Prove balance >= minimum without revealing balance | 972 | 5 |
| **validity_proof** | Prove intent authorization without revealing sender | 1113 | 6 |
| **fulfillment_proof** | Prove fulfillment correctness | 1691 | 8 |

**Total: 19 tests passing**

## Structure

```
circuits/
├── funding_proof/
│   ├── Nargo.toml
│   └── src/main.nr
├── validity_proof/
│   ├── Nargo.toml
│   ├── src/main.nr
│   └── target/validity_proof.json  ✅ Compiled
├── fulfillment_proof/
│   ├── Nargo.toml
│   ├── src/main.nr
│   └── target/fulfillment_proof.json  ✅ Compiled
├── README.md
└── CLAUDE.md
```

**Note:** Run `nargo compile` in `funding_proof/` to generate its artifact.

## Development

```bash
# Install Nargo
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup

# Compile a circuit
cd funding_proof && nargo compile

# Run tests
nargo test

# Get circuit info
nargo info

# Generate proof (requires Prover.toml with inputs)
nargo prove

# Verify proof
nargo verify
```

## Running All Tests

```bash
# From circuits directory
cd funding_proof && nargo test && cd ..
cd validity_proof && nargo test && cd ..
cd fulfillment_proof && nargo test && cd ..
```

## Circuit Details

### Funding Proof

Proves that a user has sufficient balance without revealing the actual amount.

**Public Inputs:**
- `commitment_hash` - Hash of Pedersen commitment to balance
- `minimum_required` - Minimum balance required
- `asset_id` - Asset identifier

**Private Inputs:**
- `balance` - Actual user balance
- `blinding` - Commitment blinding factor

### Validity Proof

Proves intent authorization without revealing sender identity.

**Public Inputs:**
- `intent_hash` - Hash of the intent
- `sender_commitment_x/y` - Commitment to sender identity
- `nullifier` - Prevents double-spending
- `timestamp`, `expiry` - Time bounds

**Private Inputs:**
- `sender_address` - Actual sender
- `sender_blinding` - Commitment blinding
- `sender_secret` - For nullifier derivation
- ECDSA signature data

### Fulfillment Proof

Proves correct swap execution with oracle attestation.

**Public Inputs:**
- `intent_hash` - Intent being fulfilled
- `output_commitment_x/y` - Commitment to output amount
- `recipient_stealth` - Delivery address
- `min_output_amount` - Required minimum
- `solver_id` - Solver identifier
- `fulfillment_time`, `expiry` - Time bounds

**Private Inputs:**
- `output_amount` - Actual delivered amount
- `output_blinding` - Commitment blinding
- `solver_secret` - Derives solver_id
- Oracle attestation data and signature

## Specifications

See detailed specifications:
- [Funding Proof Spec](https://docs.sip-protocol.org/specs/funding-proof/)
- [Validity Proof Spec](https://docs.sip-protocol.org/specs/validity-proof/)
- [Fulfillment Proof Spec](https://docs.sip-protocol.org/specs/fulfillment-proof/)

## Integration

The compiled JSON artifacts are used by the SDK's `NoirProofProvider`:

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

## Related

- [sip-protocol](https://github.com/sip-protocol/sip-protocol) - Core SDK
- [Noir Documentation](https://noir-lang.org/docs)

---

*Part of the [SIP Protocol](https://github.com/sip-protocol) ecosystem*
