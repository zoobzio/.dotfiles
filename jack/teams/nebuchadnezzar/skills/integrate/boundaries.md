# Boundary Transformation Testing

Testing that data transformations at system boundaries produce correct results when using real `sum.Boundary` instances.

## Encryption/Decryption Roundtrips

Test that data survives a full encrypt-then-decrypt cycle with the real boundary processor.

```go
func TestEncryptionRoundtrip(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithEncryption(realKey))

    original := "sensitive-data"
    encrypted, err := boundary.OnEntry(original)
    if err != nil {
        t.Fatalf("encrypt: %v", err)
    }

    if encrypted == original {
        t.Fatal("encrypted value must differ from original")
    }

    decrypted, err := boundary.OnSend(encrypted)
    if err != nil {
        t.Fatalf("decrypt: %v", err)
    }

    if decrypted != original {
        t.Fatalf("roundtrip mismatch: got %q, want %q", decrypted, original)
    }
}
```

Test with varied input: empty strings, unicode, binary data, maximum-length values.

```go
func TestEncryptionRoundtrip_Varied(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithEncryption(realKey))

    cases := []struct {
        name  string
        input string
    }{
        {"empty", ""},
        {"unicode", "\u00e4\u00f6\u00fc\u00df\u2603"},
        {"long", strings.Repeat("x", 10000)},
        {"special chars", "foo\x00bar\nqux"},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            encrypted, err := boundary.OnEntry(tc.input)
            AssertNoError(t, err)

            decrypted, err := boundary.OnSend(encrypted)
            AssertNoError(t, err)

            if decrypted != tc.input {
                t.Fatalf("roundtrip failed for %q", tc.name)
            }
        })
    }
}
```

## Masking Output Patterns

Test that masking produces the expected output pattern. Masking is a one-way transformation — verify the shape, not reversibility.

```go
func TestMaskingPattern(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithMasking("email"))

    input := "user@example.com"
    masked, err := boundary.OnSend(input)
    if err != nil {
        t.Fatalf("mask: %v", err)
    }

    // Verify the masked output matches the expected pattern
    if !strings.Contains(masked, "***") {
        t.Fatalf("expected masked output, got %q", masked)
    }

    // Verify original is not recoverable from masked value
    if masked == input {
        t.Fatal("masking must alter the value")
    }
}
```

Test masking across field types:

```go
func TestMaskingFieldTypes(t *testing.T) {
    cases := []struct {
        name    string
        kind    string
        input   string
        pattern string // regex pattern the masked output must match
    }{
        {"email", "email", "user@example.com", `^u\*+@.*\.com$`},
        {"phone", "phone", "+1-555-123-4567", `^\+1-\*+-4567$`},
        {"ssn", "ssn", "123-45-6789", `^\*+-6789$`},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            boundary := sum.NewBoundary(sum.WithMasking(tc.kind))
            masked, err := boundary.OnSend(tc.input)
            AssertNoError(t, err)

            matched, _ := regexp.MatchString(tc.pattern, masked)
            if !matched {
                t.Fatalf("masked %q does not match pattern %q: got %q", tc.name, tc.pattern, masked)
            }
        })
    }
}
```

## Hashing Verification

Test that hashing produces deterministic, verifiable results.

```go
func TestHashingDeterminism(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithHashing("sha256"))

    input := "consistent-input"
    hash1, err := boundary.OnEntry(input)
    AssertNoError(t, err)

    hash2, err := boundary.OnEntry(input)
    AssertNoError(t, err)

    if hash1 != hash2 {
        t.Fatal("same input must produce same hash")
    }
}

func TestHashingUniqueness(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithHashing("sha256"))

    hash1, _ := boundary.OnEntry("input-a")
    hash2, _ := boundary.OnEntry("input-b")

    if hash1 == hash2 {
        t.Fatal("different inputs must produce different hashes")
    }
}
```

Test that hashed values have the expected format and length:

```go
func TestHashingFormat(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithHashing("sha256"))

    hashed, err := boundary.OnEntry("test")
    AssertNoError(t, err)

    if len(hashed) != 64 { // SHA-256 hex-encoded
        t.Fatalf("expected 64-char hex string, got %d chars", len(hashed))
    }

    matched, _ := regexp.MatchString(`^[a-f0-9]{64}$`, hashed)
    if !matched {
        t.Fatalf("hash is not valid hex: %q", hashed)
    }
}
```

## OnEntry/OnSend Lifecycle

Test the full lifecycle with real `sum.Boundary` instances to verify that OnEntry (inbound) and OnSend (outbound) transformations compose correctly.

```go
func TestBoundaryLifecycle(t *testing.T) {
    boundary := sum.NewBoundary(
        sum.WithEncryption(realKey),
    )

    // OnEntry: data coming into the system
    stored, err := boundary.OnEntry("plaintext-value")
    AssertNoError(t, err)

    if stored == "plaintext-value" {
        t.Fatal("OnEntry must transform the value")
    }

    // OnSend: data leaving the system
    sent, err := boundary.OnSend(stored)
    AssertNoError(t, err)

    if sent != "plaintext-value" {
        t.Fatalf("OnSend must restore the original: got %q", sent)
    }
}
```

Test boundaries with multiple transformations chained:

```go
func TestBoundaryChain(t *testing.T) {
    // Boundary that encrypts on entry and masks on send
    boundary := sum.NewBoundary(
        sum.WithEncryption(realKey),
        sum.WithMasking("email"),
    )

    stored, err := boundary.OnEntry("user@example.com")
    AssertNoError(t, err)

    // Stored value is encrypted
    if stored == "user@example.com" {
        t.Fatal("stored value must be encrypted")
    }

    // Sent value is masked (not decrypted to plaintext)
    sent, err := boundary.OnSend(stored)
    AssertNoError(t, err)

    if sent == "user@example.com" {
        t.Fatal("sent value must be masked, not plaintext")
    }
}
```

Test error cases: invalid keys, corrupted data, mismatched boundary configurations.

```go
func TestBoundaryErrors(t *testing.T) {
    boundary := sum.NewBoundary(sum.WithEncryption(realKey))

    // Corrupted ciphertext
    _, err := boundary.OnSend("not-valid-ciphertext")
    if err == nil {
        t.Fatal("expected error for corrupted ciphertext")
    }

    // Wrong key
    other := sum.NewBoundary(sum.WithEncryption(differentKey))
    encrypted, _ := boundary.OnEntry("secret")
    _, err = other.OnSend(encrypted)
    if err == nil {
        t.Fatal("expected error for wrong decryption key")
    }
}
```
