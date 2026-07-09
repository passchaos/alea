# S4-M1100 ASCII Charset Checked Fill Facade Direct Path

## Gap

Reusable ASCII `Charset.fillChecked` still delegated the facade checked byte-fill
helper through `fillCheckedFrom(rng, ...)`. The unchecked facade fill path now
samples directly, so the checked facade can validate first and then call
`fill(rng, ...)` directly instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for character/string
sampling ergonomics. Alea exposes checked reusable ASCII charset caller-owned byte
fills; this change tightens the checked facade path without changing byte
selection, empty validation, stream shape, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.fillChecked` to return early for zero-length
  output, reject empty charsets before entropy use, and call direct facade
  `fill(rng, out)`.
- `Charset.fillCheckedFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused ASCII charset tests:

```text
$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "single-byte charset helpers do not consume random stream"
1/2 ascii.test.single-byte charset helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "invalid charset init does not consume random stream"
1/2 ascii.test.invalid charset init does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M1100 is closed for the current bar: reusable ASCII `Charset.fillChecked` now
avoids the direct-source checked wrapper alias while preserving stream shape,
empty validation, caller-owned byte output behavior, and singleton no-consume
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
