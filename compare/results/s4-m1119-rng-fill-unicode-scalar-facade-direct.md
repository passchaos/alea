# S4-M1119 Rng FillUnicodeScalar Facade Direct Path

## Gap

`Rng.fillUnicodeScalar` still delegated the facade caller-owned Unicode scalar
fill helper through `fillUnicodeScalarFrom(self, ...)`. The scalar facade now
samples Unicode scalars directly through facade range sampling, so caller-owned
Unicode scalar fills can loop over facade `unicodeScalar` directly instead of
bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`char`-style workflows. Alea exposes Zig-native `u21` Unicode scalar fill helpers
with surrogate-gap handling. This change tightens the facade fill path without
changing scalar selection, caller-owned output behavior, stream shape, surrogate
exclusion, or downstream UTF-8 string behavior.

## Implementation

- `src/rng.zig` updates `Rng.fillUnicodeScalar` to fill caller-owned output by
  repeatedly calling direct facade `unicodeScalar`.
- `Rng.fillUnicodeScalarFrom` remains unchanged for explicit direct-source
  workflows.
- Existing Unicode scalar stream-shape tests now cover facade fill parity against
  manual direct-source scalar draws.

## Validation

Focused Unicode/ASCII tests:

```text
$ zig test src/rng.zig --test-filter "unicode scalar fills and batches preserve scalar stream shape"
1/2 rng.test.unicode scalar fills and batches preserve scalar stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode scalar string generation produces valid utf8"
1/2 ascii.test.unicode scalar string generation produces valid utf8...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M1119 is closed for the current bar: `Rng.fillUnicodeScalar` now avoids the
`fillUnicodeScalarFrom` direct-source wrapper alias while preserving stream
shape, caller-owned output behavior, surrogate-gap mapping, and valid Unicode
scalar output. This is reliability / ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
