# S4-M1120 Rng Fill Unicode Scalar Range Facade Direct Paths

## Gap

`Rng.fillUnicodeScalarRangeLessThan` and `Rng.fillUnicodeScalarRangeAtMost`
still delegated facade caller-owned bounded Unicode scalar fills through their
`From` wrappers. The scalar range facade helpers now perform compressed-range
validation/mapping and surrogate-gap handling directly, so caller-owned range
fills can apply the same logic through facade integer range primitives without
wrapper dispatch.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`UniformChar`-style workflows. Alea exposes Zig-native `u21` Unicode scalar range
fills with surrogate-gap handling. This change tightens the facade range fill
paths without changing scalar selection, caller-owned output behavior, stream
shape, invalid-range behavior, empty-output no-consume behavior, degenerate
no-consume behavior, or surrogate exclusion.

## Implementation

- `src/rng.zig` updates `Rng.fillUnicodeScalarRangeLessThan` to validate the
  compressed half-open scalar range, handle empty and degenerate outputs, and
  fill through facade `intRangeLessThan`.
- `src/rng.zig` updates `Rng.fillUnicodeScalarRangeAtMost` to validate the
  compressed inclusive scalar range, handle empty and degenerate outputs, and
  fill through facade `intRangeAtMost`.
- Direct-source range fill helpers remain unchanged for explicit direct-source
  workflows.

## Validation

Focused Unicode tests:

```text
$ zig test src/rng.zig --test-filter "unicode scalar range helpers preserve checked stream shape"
1/2 rng.test.unicode scalar range helpers preserve checked stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "unicode scalar ranges handle surrogate gap and degenerate ranges"
1/2 rng.test.unicode scalar ranges handle surrogate gap and degenerate ranges...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "invalid unicode scalar ranges do not consume random stream"
1/2 rng.test.invalid unicode scalar ranges do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1120 is closed for the current bar: bounded Unicode scalar facade fill
helpers now avoid direct-source range fill wrapper aliases while preserving
stream shape, caller-owned output behavior, surrogate-gap mapping, empty-output
no-consume behavior, degenerate no-consume behavior, and valid Unicode scalar
output. This is reliability / ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
