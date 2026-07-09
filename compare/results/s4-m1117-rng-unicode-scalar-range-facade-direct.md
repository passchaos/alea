# S4-M1117 Rng Unicode Scalar Range Facade Direct Paths

## Gap

`Rng.unicodeScalarRangeLessThan` and `Rng.unicodeScalarRangeAtMost` still
delegated facade bounded Unicode scalar helpers through their direct-source
`From` wrappers. The compressed-range validation/mapping logic is small and can
call facade integer range primitives directly, preserving surrogate-gap handling
without wrapper dispatch.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`UniformChar`-style workflows. Alea exposes Zig-native `u21` Unicode scalar range
helpers with surrogate-gap handling. This change tightens the facade scalar range
paths without changing scalar selection, stream shape, invalid-range behavior,
degenerate no-consume behavior, or surrogate exclusion.

## Implementation

- `src/rng.zig` updates `Rng.unicodeScalarRangeLessThan` to validate the
  compressed half-open scalar range and sample through facade `intRangeLessThan`.
- `src/rng.zig` updates `Rng.unicodeScalarRangeAtMost` to validate the compressed
  inclusive scalar range and sample through facade `intRangeAtMost`.
- Direct-source `unicodeScalarRangeLessThanFrom` and
  `unicodeScalarRangeAtMostFrom` remain unchanged for explicit direct-source
  workflows.

## Validation

Focused Unicode/ASCII tests:

```text
$ zig test src/rng.zig --test-filter "unicode scalar range helpers preserve checked stream shape"
1/2 rng.test.unicode scalar range helpers preserve checked stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "unicode scalar ranges handle surrogate gap and degenerate ranges"
1/2 rng.test.unicode scalar ranges handle surrogate gap and degenerate ranges...OK
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
apicheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M1117 is closed for the current bar: bounded Unicode scalar facade helpers now
avoid direct-source wrapper aliases while preserving stream shape,
surrogate-gap mapping, degenerate no-consume behavior, and valid Unicode scalar
output. This is reliability / ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
