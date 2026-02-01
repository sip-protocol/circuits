<div align="center">

<pre>
███████╗ ██╗ ██████╗      ██████╗██╗██████╗  ██████╗██╗   ██╗██╗████████╗███████╗
██╔════╝ ██║ ██╔══██╗    ██╔════╝██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝██╔════╝
███████╗ ██║ ██████╔╝    ██║     ██║██████╔╝██║     ██║   ██║██║   ██║   ███████╗
╚════██║ ██║ ██╔═══╝     ██║     ██║██╔══██╗██║     ██║   ██║██║   ██║   ╚════██║
███████║ ██║ ██║         ╚██████╗██║██║  ██║╚██████╗╚██████╔╝██║   ██║   ███████║
╚══════╝ ╚═╝ ╚═╝          ╚═════╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝
</pre>

# SIP Circuits

> **Privacy is not a feature. It's a right.**

**Zero-knowledge proof circuits for SIP Protocol — prove without revealing**

*Funding proofs • Validity proofs • Fulfillment proofs • Browser-compatible*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Noir](https://img.shields.io/badge/Noir-1.0.0--beta.15-8B5CF6)](https://noir-lang.org/)
[![Barretenberg](https://img.shields.io/badge/Backend-UltraHonk-purple)](https://github.com/AztecProtocol/barretenberg)
[![Tests](https://img.shields.io/badge/Tests-19_passing-brightgreen)](.)

**🏆 Winner — [Zypherpunk Hackathon](https://zypherpunk.xyz) ($6,500: NEAR $4,000 + Tachyon $500 + pumpfun $2,000) | #9 of 93 | 3 Tracks**

</div>

---

## Table of Contents

- [What are SIP Circuits?](#-what-are-sip-circuits)
- [Circuits Overview](#-circuits-overview)
- [Quick Start](#-quick-start)
- [Circuit Details](#-circuit-details)
- [Architecture](#%EF%B8%8F-architecture)
- [Cryptographic Primitives](#-cryptographic-primitives)
- [Integration](#-integration)
- [Development](#-development)
- [Specifications](#-specifications)
- [Related Projects](#-related-projects)
- [License](#-license)

---

## 🛡️ What are SIP Circuits?

SIP Circuits are **zero-knowledge proof circuits** written in Noir that enable privacy-preserving operations without revealing sensitive data. They're the cryptographic backbone of SIP Protocol.

```
Traditional Transaction  → Everyone sees balance, amount, recipient
SIP with ZK Proofs       → Prove validity without revealing anything
```

**Prove you have enough. Prove you're authorized. Prove it's correct. Reveal nothing.**

---

## 📊 Circuits Overview

| Circuit | Purpose | ACIR Opcodes | Tests |
|---------|---------|--------------|-------|
| **funding_proof** | Prove balance ≥ minimum without revealing balance | 972 | 5 |
| **validity_proof** | Prove intent authorization without revealing sender | 1,113 | 6 |
| **fulfillment_proof** | Prove swap execution correctness | 1,691 | 8 |

**Total: 3 circuits, 3,776 ACIR opcodes, 19 tests passing**

### What Each Circuit Proves

```
┌─────────────────────────────────────────────────────────────────┐
│  FUNDING PROOF                                                  │
│  "I have enough balance"                                        │
│  ─────────────────────                                          │
│  Public:  commitment_hash, minimum_required, asset_id           │
│  Private: actual_balance, blinding_factor                       │
│  Proves:  balance >= minimum (without revealing balance)        │
├─────────────────────────────────────────────────────────────────┤
│  VALIDITY PROOF                                                 │
│  "I authorized this intent"                                     │
│  ─────────────────────────                                      │
│  Public:  intent_hash, sender_commitment, nullifier, timestamps │
│  Private: sender_address, signature, secrets                    │
│  Proves:  valid signature from committed sender                 │
├─────────────────────────────────────────────────────────────────┤
│  FULFILLMENT PROOF                                              │
│  "The swap was executed correctly"                              │
│  ─────────────────────────────────                              │
│  Public:  intent_hash, output_commitment, recipient, min_output │
│  Private: actual_output, oracle_attestation                     │
│  Proves:  output >= min_output with oracle verification         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- [Nargo CLI](https://noir-lang.org/docs/getting_started/installation)

### Installation

```bash
# Install Nargo (Noir's package manager)
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup

# Clone the repository
git clone https://github.com/sip-protocol/circuits.git
cd circuits
```

### Compile & Test

```bash
# Compile a circuit
cd funding_proof
nargo compile

# Run tests
nargo test

# Get circuit info (constraint count)
nargo info

# Generate a proof (requires Prover.toml)
nargo prove

# Verify a proof
nargo verify
```

### Run All Tests

```bash
# From circuits root
cd funding_proof && nargo test && cd ..
cd validity_proof && nargo test && cd ..
cd fulfillment_proof && nargo test && cd ..
```

---

## 🔐 Circuit Details

### 1. Funding Proof

Proves that a user has sufficient balance without revealing the actual amount.

**Use case:** Pre-validate that user can afford a swap before execution.

```noir
// Public Inputs
commitment_hash: [u8; 32]   // Hash of Pedersen commitment to balance
minimum_required: u64       // Minimum balance required
asset_id: Field             // Asset identifier

// Private Inputs (never revealed)
balance: u64                // Actual user balance
blinding: Field             // Commitment blinding factor
```

**Verification:**
1. Recompute commitment from `balance` and `blinding`
2. Verify commitment hash matches public input
3. Assert `balance >= minimum_required`

### 2. Validity Proof

Proves intent authorization without revealing sender identity.

**Use case:** Authorize a swap intent while hiding who's swapping.

```noir
// Public Inputs
intent_hash: Field                  // Hash of the intent
sender_commitment_x: Field          // Commitment X coordinate
sender_commitment_y: Field          // Commitment Y coordinate
nullifier: Field                    // Prevents double-spending
timestamp: u64                      // Current timestamp
expiry: u64                         // Intent expiry time

// Private Inputs (never revealed)
sender_address: Field               // Actual sender address
sender_blinding: Field              // Commitment blinding
sender_secret: Field                // For nullifier derivation
pub_key_x: [u8; 32]                 // ECDSA public key X
pub_key_y: [u8; 32]                 // ECDSA public key Y
signature: [u8; 64]                 // ECDSA signature
message_hash: [u8; 32]              // Signed message hash
nonce: Field                        // Unique nonce
```

**Verification:**
1. Verify ECDSA signature on message
2. Verify sender commitment matches address
3. Verify nullifier derivation
4. Check timestamp within expiry

### 3. Fulfillment Proof

Proves correct swap execution with oracle attestation.

**Use case:** Verify solver delivered correct output amount.

```noir
// Public Inputs
intent_hash: Field                  // Intent being fulfilled
output_commitment_x: Field          // Output commitment X
output_commitment_y: Field          // Output commitment Y
recipient_stealth: Field            // Stealth delivery address
min_output_amount: u64              // Required minimum output
solver_id: Field                    // Solver identifier
fulfillment_time: u64               // When fulfilled
expiry: u64                         // Must fulfill before

// Private Inputs (never revealed)
output_amount: u64                  // Actual delivered amount
output_blinding: Field              // Commitment blinding
solver_secret: Field                // Derives solver_id
oracle_recipient: Field             // Oracle-attested recipient
oracle_amount: u64                  // Oracle-attested amount
oracle_tx_hash: [u8; 32]            // Transaction hash
oracle_block: u64                   // Block number
oracle_signature: [u8; 64]          // Oracle signature
oracle_message_hash: [u8; 32]       // Signed message
oracle_pub_key_x: [u8; 32]          // Oracle public key
oracle_pub_key_y: [u8; 32]
```

**Verification:**
1. Verify oracle signature on attestation
2. Verify output commitment matches amount
3. Assert `output_amount >= min_output_amount`
4. Verify solver_id derivation
5. Check fulfillment within expiry

---

## 🏗️ Architecture

### Project Structure

```
circuits/
├── funding_proof/
│   ├── Nargo.toml                  # Circuit manifest
│   ├── src/
│   │   └── main.nr                 # Circuit implementation
│   └── target/
│       └── funding_proof.json      # Compiled artifact
│
├── validity_proof/
│   ├── Nargo.toml
│   ├── src/
│   │   └── main.nr
│   └── target/
│       └── validity_proof.json     # ✅ Compiled
│
├── fulfillment_proof/
│   ├── Nargo.toml
│   ├── src/
│   │   └── main.nr
│   └── target/
│       └── fulfillment_proof.json  # ✅ Compiled
│
├── README.md
└── CLAUDE.md
```

### Proof Flow

```
Private Inputs + Public Inputs → Noir Circuit → ACIR → Barretenberg → Proof
                                                              │
                                                              ▼
                                                    SDK Verifies Proof
                                                    (Browser or Server)
```

---

## 🔢 Cryptographic Primitives

| Primitive | Usage | Noir Standard Library |
|-----------|-------|----------------------|
| **Pedersen Hash** | Commitments, nullifiers | `std::hash::pedersen_hash` |
| **BLAKE3** | Commitment binding, message hashing | `std::hash::blake3` |
| **ECDSA secp256k1** | Signature verification | `std::ecdsa_secp256k1::verify_signature` |

### Why These Primitives?

- **Pedersen**: Additively homomorphic, efficient in ZK circuits
- **BLAKE3**: Fast, secure, small circuit size
- **ECDSA secp256k1**: Compatible with Ethereum/Bitcoin signatures

---

## 🔌 Integration

### SDK Integration

Compiled JSON artifacts are used by the SDK's `NoirProofProvider`:

```typescript
import { NoirProofProvider } from '@sip-protocol/sdk'

// Initialize provider (loads WASM)
const provider = new NoirProofProvider()
await provider.initialize()

// Generate a funding proof
const result = await provider.generateFundingProof({
  balance: 100n,
  minimumRequired: 50n,
  blindingFactor: new Uint8Array(32),
  assetId: '0xABCD',
})

console.log(result.proof)       // Proof bytes
console.log(result.publicInputs) // Public inputs
```

### Browser Proving

Circuits are optimized for browser execution via WASM:

```typescript
import { BrowserNoirProvider } from '@sip-protocol/sdk'

// Browser-compatible proving
const provider = new BrowserNoirProvider()
await provider.initialize()

// Proof generation happens client-side
const proof = await provider.generateFundingProof({ ... })
```

---

## 💻 Development

### Commands

```bash
nargo compile    # Compile circuit to ACIR
nargo test       # Run circuit tests
nargo info       # Show constraint count
nargo prove      # Generate proof (needs Prover.toml)
nargo verify     # Verify proof
nargo check      # Type check without compiling
```

### Writing Tests

```noir
// In src/main.nr
#[test]
fn test_valid_funding() {
    let balance = 100;
    let minimum = 50;
    let blinding = 12345;

    // This should pass
    main(
        pedersen_hash(balance, blinding),
        minimum,
        1, // asset_id
        balance,
        blinding
    );
}

#[test(should_fail)]
fn test_insufficient_balance() {
    let balance = 30;
    let minimum = 50;
    // This should fail: 30 < 50
    main(...);
}
```

### Adding a New Circuit

1. Create directory: `mkdir new_circuit && cd new_circuit`
2. Initialize: `nargo init`
3. Implement circuit in `src/main.nr`
4. Add tests
5. Compile: `nargo compile`
6. Integrate with SDK

---

## 📋 Specifications

Detailed specifications in documentation:

| Spec | Link |
|------|------|
| Funding Proof | [docs.sip-protocol.org/specs/funding-proof](https://docs.sip-protocol.org/specs/funding-proof) |
| Validity Proof | [docs.sip-protocol.org/specs/validity-proof](https://docs.sip-protocol.org/specs/validity-proof) |
| Fulfillment Proof | [docs.sip-protocol.org/specs/fulfillment-proof](https://docs.sip-protocol.org/specs/fulfillment-proof) |

---

## 🔗 Related Projects

| Project | Description | Link |
|---------|-------------|------|
| **sip-protocol** | Core SDK (uses compiled circuits) | [GitHub](https://github.com/sip-protocol/sip-protocol) |
| **docs-sip** | Circuit specifications | [docs.sip-protocol.org](https://docs.sip-protocol.org) |
| **Noir** | ZK DSL documentation | [noir-lang.org](https://noir-lang.org/docs) |
| **Barretenberg** | Proving backend | [GitHub](https://github.com/AztecProtocol/barretenberg) |

---

## 📄 License

[MIT License](LICENSE) — see LICENSE file for details.

---

<div align="center">

**🏆 Zypherpunk Hackathon Winner ($6,500) | #9 of 93 | 3 Tracks**

*Privacy is not a feature. It's a right.*

[Documentation](https://docs.sip-protocol.org/specs) · [Noir Docs](https://noir-lang.org/docs) · [Report Bug](https://github.com/sip-protocol/circuits/issues)

*Part of the [SIP Protocol](https://github.com/sip-protocol) ecosystem*

</div>
