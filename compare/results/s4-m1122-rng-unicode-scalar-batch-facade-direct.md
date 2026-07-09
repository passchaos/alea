# S4-M1122 Rng Unicode Scalar Batch Facade Direct Path

## Gap

`Rng.unicodeScalarBatch` still delegated the allocation-returning facade Unicode
scalar batch helper through `unicodeScalarBatchFrom(self, ...)`. The caller-owned
facade fill now loops over direct facade `unicodeScalar`, so the owned facade
batch can allocate and fill directly without wrapper dispatch.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`char`-style repeated workflows. Alea exposes Zig-native `u21` Unicode scalar
owned batches with surrogate-gap handling. This change tightens the facade owned
batch path without changing scalar selection, allocation ownership, stream shape,
zero-count behavior, allocation-failure no-consume behavior, or surrogate
exclusion.

## Implementation

- `src/rng.zig` updates `Rng.unicodeScalarBatch` to allocate, call direct facade
  `fillUnicodeScalar`, and return the owned slice.
- `Rng.unicodeScalarBatchFrom` remains unchanged for explicit direct-source
  workflows.
- Existing Unicode scalar stream-shape and allocation-failure tests now cover the
  facade owned batch path directly.

## Validation

Focused Unicode tests:

```text
$ zig test src/rng.zig --test-filter "unicode scalar fills and batches preserve scalar stream shape"
1/2 rng.test.unicode scalar fills and batches preserve scalar stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "owned unicode scalar batches allocate before consuming random stream"
1/2 rng.test.owned unicode scalar batches allocate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode scalar string generation produces valid utf8"
1/2 ascii.test.unicode scalar string generation produces valid utf8...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1122 is closed for the current bar: `Rng.unicodeScalarBatch` now avoids the
`unicodeScalarBatchFrom` direct-source wrapper alias while preserving stream
shape, allocation ownership, zero-count behavior, allocation-failure no-consume
behavior, surrogate-gap mapping, and valid Unicode scalar output. This is
reliability / ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
