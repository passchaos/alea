# S4-M1121 Rng Checked Fill Unicode Scalar Range Facade Direct Paths

## Gap

`Rng.fillUnicodeScalarRangeLessThanChecked` and
`Rng.fillUnicodeScalarRangeAtMostChecked` still delegated checked caller-owned
bounded Unicode scalar fills through checked `From` wrappers. The unchecked
facade range fill helpers now perform compressed-range sampling and surrogate-gap
mapping directly, so checked facade fills can validate and call those direct
facade paths without wrapper dispatch.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for Unicode scalar / Rust
`UniformChar`-style workflows. Alea exposes Zig-native checked `u21` Unicode
scalar range fills with surrogate-gap validation. This change tightens checked
facade range fill paths without changing scalar selection, caller-owned output
behavior, stream shape, invalid-range no-consume behavior, empty-output
no-consume behavior, degenerate no-consume behavior, or surrogate exclusion.

## Implementation

- `src/rng.zig` updates `Rng.fillUnicodeScalarRangeLessThanChecked` to keep
  empty-output no-op behavior, validate the compressed half-open scalar range,
  then call direct facade `fillUnicodeScalarRangeLessThan`.
- `src/rng.zig` updates `Rng.fillUnicodeScalarRangeAtMostChecked` to keep
  empty-output no-op behavior, validate the compressed inclusive scalar range,
  then call direct facade `fillUnicodeScalarRangeAtMost`.
- Direct-source checked range fill helpers remain unchanged for explicit
  direct-source workflows.

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
readmecheck ok
apicheck ok
```

## Result

S4-M1121 is closed for the current bar: checked bounded Unicode scalar facade
fill helpers now avoid checked direct-source fill wrapper aliases while
preserving stream shape, caller-owned output behavior, surrogate-gap mapping,
invalid-range no-consume behavior, empty-output no-consume behavior, degenerate
no-consume behavior, and valid Unicode scalar output. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
