# Cryptography

What algorithms, what key management, what randomness.

## What to Find

- Algorithm choices (weak, deprecated, misused)
- Key management (hardcoded, weak generation, improper storage)
- Random number generation (crypto/rand vs math/rand)
- Hash collision resistance
- TLS configuration (cipher suites, protocol versions)

## How to Look

Every cryptographic operation is a bet. The algorithm bet, the key management bet, the randomness bet. Check each one. TLS configured with a cipher suite that was broken three years ago is not TLS. math/rand for security tokens is not randomness.
