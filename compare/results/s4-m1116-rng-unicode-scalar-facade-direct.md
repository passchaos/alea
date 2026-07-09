# S4-M1116 Rng UnicodeScalar Facade Direct Path

## Gap

`Rng.unicodeScalar` still delegated the facade Unicode scalar helper through
`unicodeScalarFrom(self)`. The scalar-generation algorithm is small and already
uses the facade integer range primitive safely, so the facade helper can perform
the surrogate-gap mapping directly instead of bouncing through the direct-source
wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`char`-style workflows. Alea exposes Zig-native `u21` Unicode scalar helpers
with surrogate-gap handling. This change tightens the facade scalar path without
changing scalar selection, stream shape, surrogate exclusion, or downstream UTF-8
string behavior.

## Implementation

- `src/rng.zig` updates `Rng.unicodeScalar` to sample the compressed scalar range
  through facade `intRangeLessThan` and map around the surrogate gap directly.
- `Rng.unicodeScalarFrom` remains unchanged for explicit direct-source
  workflows.
- Existing Unicode scalar stream-shape tests now cover scalar facade/direct
  parity before fill/batch parity.

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
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M1116 is closed for the current bar: `Rng.unicodeScalar` now avoids the
`unicodeScalarFrom` direct-source wrapper alias while preserving stream shape,
surrogate-gap mapping, and valid Unicode scalar output. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
