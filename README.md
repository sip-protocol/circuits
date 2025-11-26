# circuits

> Noir ZK Circuits for SIP Protocol

---

## Overview

Zero-knowledge proof circuits for the **SIP Protocol** (Shielded Intents Protocol).

## Tech Stack

- **Language:** [Noir](https://noir-lang.org/)
- **Backend:** Barretenberg (default), Halo2 (future)
- **Tooling:** Nargo CLI

## Circuits (Planned)

| Circuit | Purpose | Status |
|---------|---------|--------|
| **Funding Proof** | Prove balance ≥ minimum without revealing balance | 📋 Spec complete |
| **Validity Proof** | Prove intent authorization without revealing sender | 📋 Spec complete |
| **Fulfillment Proof** | Prove fulfillment correctness | 📋 Spec complete |

## Structure (Planned)

```
circuits/
├── funding_proof/
│   ├── src/
│   │   └── main.nr
│   └── Nargo.toml
├── validity_proof/
│   ├── src/
│   │   └── main.nr
│   └── Nargo.toml
├── fulfillment_proof/
│   ├── src/
│   │   └── main.nr
│   └── Nargo.toml
└── README.md
```

## Development

```bash
# Install Nargo
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup

# Compile circuit
cd funding_proof && nargo compile

# Run tests
nargo test

# Generate proof
nargo prove

# Verify proof
nargo verify
```

## Specifications

See detailed specifications in the main repo:
- [Funding Proof Spec](https://github.com/sip-protocol/sip-protocol/blob/main/docs/specs/FUNDING-PROOF.md)
- [Validity Proof Spec](https://github.com/sip-protocol/sip-protocol/blob/main/docs/specs/VALIDITY-PROOF.md)
- [Fulfillment Proof Spec](https://github.com/sip-protocol/sip-protocol/blob/main/docs/specs/FULFILLMENT-PROOF.md)

## Related

- [sip-protocol](https://github.com/sip-protocol/sip-protocol) - Core SDK
- [Noir Documentation](https://noir-lang.org/docs)

---

*Part of the [SIP Protocol](https://github.com/sip-protocol) ecosystem*
