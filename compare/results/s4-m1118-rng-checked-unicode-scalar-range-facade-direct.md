# S4-M1118 Rng Checked Unicode Scalar Range Facade Direct Paths

## Gap

`Rng.unicodeScalarRangeLessThanChecked` and
`Rng.unicodeScalarRangeAtMostChecked` still delegated checked bounded Unicode
scalar helpers through their direct-source `From` wrappers. The unchecked facade
range helpers now perform compressed-range sampling and surrogate-gap mapping
directly, so checked facade helpers can validate and call those direct facade
paths instead of bouncing through checked direct-source wrappers.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`UniformChar`-style workflows. Alea exposes Zig-native checked `u21` Unicode
scalar range helpers with surrogate-gap validation. This change tightens checked
facade scalar range paths without changing scalar selection, stream shape,
invalid-range no-consume behavior, degenerate no-consume behavior, or surrogate
exclusion.

## Implementation

- `src/rng.zig` updates `Rng.unicodeScalarRangeLessThanChecked` to validate the
  compressed half-open scalar range and call direct facade
  `unicodeScalarRangeLessThan`.
- `src/rng.zig` updates `Rng.unicodeScalarRangeAtMostChecked` to validate the
  compressed inclusive scalar range and call direct facade
  `unicodeScalarRangeAtMost`.
- Direct-source checked helpers remain unchanged for explicit direct-source
  workflows.

## Validation

Focused Unicode tests:

```text
$ zig test src/rng.zig --test-filter "unicode scalar range helpers preserve checked stream shape"
1/2 rng.test.unicode scalar range helpers preserve checked stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "invalid unicode scalar ranges do not consume random stream"
1/2 rng.test.invalid unicode scalar ranges do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/rng.zig --test-filter "unicode scalar ranges handle surrogate gap and degenerate ranges"
1/2 rng.test.unicode scalar ranges handle surrogate gap and degenerate ranges...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1118 is closed for the current bar: checked bounded Unicode scalar facade
helpers now avoid checked direct-source wrapper aliases while preserving stream
shape, surrogate-gap mapping, invalid-range no-consume behavior, degenerate
no-consume behavior, and valid Unicode scalar output. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
