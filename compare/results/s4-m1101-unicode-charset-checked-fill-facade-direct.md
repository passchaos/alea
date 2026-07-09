# S4-M1101 UnicodeCharset Checked Fill Facade Direct Path

## Gap

Reusable `UnicodeCharset.fillChecked` still delegated the facade checked scalar
fill helper through `fillCheckedFrom(rng, ...)`. The unchecked facade fill path
now samples directly, so the checked facade can validate first and then call
`fill(rng, ...)` directly instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for character/string
sampling ergonomics. Alea exposes checked reusable Unicode scalar caller-owned
fills; this change tightens the checked facade path without changing scalar
selection, empty/invalid validation, stream shape, or singleton no-consume
behavior.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.fillChecked` to return early for
  zero-length output, validate non-empty / valid scalar input before entropy use,
  and call direct facade `fill(rng, out)`.
- `UnicodeCharset.fillCheckedFrom` remains unchanged for explicit direct-source
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
toolingcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M1101 is closed for the current bar: reusable `UnicodeCharset.fillChecked` now
avoids the direct-source checked wrapper alias while preserving stream shape,
empty/invalid validation, caller-owned scalar output behavior, and singleton
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
