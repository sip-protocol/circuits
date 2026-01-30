/// Funding Proof Circuit
///
/// Proves that a user has sufficient balance to cover a transaction
/// without revealing the actual balance.
///
/// Public inputs:
/// - commitment_hash: Hash of the Pedersen commitment to balance
/// - minimum_required: Minimum balance required
/// - asset_id: Asset identifier
///
/// Private inputs (witness):
/// - balance: Actual user balance
/// - blinding: Blinding factor for commitment
///
/// Constraints:
/// 1. balance >= minimum_required
/// 2. commitment = pedersen([balance, blinding])
/// 3. commitment_hash = hash(commitment, asset_id)

use std::hash::pedersen_hash;
use std::hash::blake3;

/// Main entry point for the funding proof circuit
///
/// Returns the commitment hash as a public output rather than taking it as input.
/// This allows the SDK to verify the proof without needing to compute Pedersen hashes.
fn main(
    // Public inputs
    minimum_required: pub Field,
    asset_id: pub Field,

    // Private inputs (witness)
    balance: Field,
    blinding: Field,
) -> pub [u8; 32] {
    // Constraint 1: Balance must be at least the minimum required
    // Using Field comparison - works for values up to ~2^254
    assert(balance.lt(minimum_required) == false, "Insufficient balance");

    // Constraint 2: Compute the Pedersen commitment to (balance, blinding)
    let commitment = pedersen_hash([balance, blinding]);

    // Constraint 3: Compute and return the commitment hash
    // We hash: commitment || asset_id to bind the commitment to the asset
    let commitment_hash = compute_commitment_hash(commitment, asset_id);

    commitment_hash
}

/// Compute the commitment hash from commitment and asset_id
/// Uses BLAKE3 for efficiency (built-in to Noir)
fn compute_commitment_hash(commitment: Field, asset_id: Field) -> [u8; 32] {
    // Convert commitment to bytes (32 bytes, big-endian)
    let commitment_bytes: [u8; 32] = commitment.to_be_bytes();

    // Convert asset_id to bytes (32 bytes, big-endian)
    let asset_bytes: [u8; 32] = asset_id.to_be_bytes();

    // Create preimage: commitment || asset_id (64 bytes)
    let mut preimage: [u8; 64] = [0; 64];
    for i in 0..32 {
        preimage[i] = commitment_bytes[i];
        preimage[i + 32] = asset_bytes[i];
    }

    // Hash with BLAKE3
    blake3(preimage)
}

// --- Tests ---

#[test]
fn test_valid_funding_proof() {
    // Test case: balance = 100, minimum = 50
    let balance: Field = 100;
    let minimum_required: Field = 50;
    let blinding: Field = 12345;
    let asset_id: Field = 1;

    // Execute the circuit - it should return the commitment hash
    let commitment_hash = main(minimum_required, asset_id, balance, blinding);

    // Verify it returned a hash (not all zeros)
    let mut has_nonzero = false;
    for i in 0..32 {
        if commitment_hash[i] != 0 {
            has_nonzero = true;
        }
    }
    assert(has_nonzero, "Commitment hash should not be all zeros");
}

#[test]
fn test_exact_balance_passes() {
    // Test case: balance exactly equals minimum
    let balance: Field = 50;
    let minimum_required: Field = 50;
    let blinding: Field = 67890;
    let asset_id: Field = 2;

    // Should succeed and return a hash
    let _commitment_hash = main(minimum_required, asset_id, balance, blinding);
}

#[test(should_fail_with = "Insufficient balance")]
fn test_insufficient_balance_fails() {
    // Test case: balance < minimum should fail
    let balance: Field = 40;
    let minimum_required: Field = 50;
    let blinding: Field = 11111;
    let asset_id: Field = 1;

    // Should fail because balance < minimum_required
    let _commitment_hash = main(minimum_required, asset_id, balance, blinding);
}

#[test]
fn test_different_blinding_produces_different_hash() {
    // Test that different blinding factors produce different commitment hashes
    let balance: Field = 100;
    let minimum_required: Field = 50;
    let blinding1: Field = 12345;
    let blinding2: Field = 99999;
    let asset_id: Field = 1;

    let hash1 = main(minimum_required, asset_id, balance, blinding1);
    let hash2 = main(minimum_required, asset_id, balance, blinding2);

    // Hashes should be different
    let mut hashes_differ = false;
    for i in 0..32 {
        if hash1[i] != hash2[i] {
            hashes_differ = true;
        }
    }
    assert(hashes_differ, "Different blindings should produce different hashes");
}

#[test]
fn test_large_values_near_scale() {
    // Test with NEAR-scale values (24 decimals)
    // 1.5 NEAR = 1500000000000000000000000 yoctoNEAR
    // This would overflow u64 but works with Field
    let balance: Field = 1500000000000000000000000;
    let minimum_required: Field = 1000000000000000000000000; // 1 NEAR
    let blinding: Field = 999999999;
    let asset_id: Field = 0x4e454152; // "NEAR" as hex

    // Should succeed - balance > minimum
    let commitment_hash = main(minimum_required, asset_id, balance, blinding);

    // Verify hash is valid
    let mut has_nonzero = false;
    for i in 0..32 {
        if commitment_hash[i] != 0 {
            has_nonzero = true;
        }
    }
    assert(has_nonzero, "Commitment hash should not be all zeros");
}

#[test(should_fail_with = "Insufficient balance")]
fn test_large_values_insufficient() {
    // Test insufficient balance with NEAR-scale values
    let balance: Field = 500000000000000000000000; // 0.5 NEAR
    let minimum_required: Field = 1000000000000000000000000; // 1 NEAR
    let blinding: Field = 12345;
    let asset_id: Field = 0x4e454152;

    // Should fail - balance < minimum
    let _hash = main(minimum_required, asset_id, balance, blinding);
}
