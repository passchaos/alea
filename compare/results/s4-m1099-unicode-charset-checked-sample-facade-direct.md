# S4-M1099 UnicodeCharset Checked Sample Facade Direct Path

## Gap

Reusable `UnicodeCharset.sampleChecked` still delegated the facade checked scalar
helper through `sampleCheckedFrom(rng)`. The unchecked facade scalar path now
samples directly, so the checked facade can validate first and then call
`sample(rng)` directly instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for character/string
sampling ergonomics. Alea exposes checked reusable Unicode scalar sampling; this
change tightens the checked facade path without changing scalar selection, empty
/ invalid validation, stream shape, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.sampleChecked` to validate non-empty /
  valid scalar input before entropy use, then call direct facade `sample(rng)`.
- `UnicodeCharset.sampleCheckedFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused Unicode charset tests:

```text
$ zig test src/ascii.zig --test-filter "unicode charset helpers preserve direct stream shape"
1/2 ascii.test.unicode charset helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode charset checked helpers validate without consuming"
1/2 ascii.test.unicode charset checked helpers validate without consuming...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "single-scalar unicode charset helpers do not consume random stream"
1/2 ascii.test.single-scalar unicode charset helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M1099 is closed for the current bar: reusable `UnicodeCharset.sampleChecked`
now avoids the direct-source checked wrapper alias while preserving stream shape,
empty/invalid validation, scalar output behavior, and singleton no-consume
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
