# S4-M1097 ASCII Charset Checked Sample Facade Direct Path

## Gap

Reusable ASCII `Charset.sampleChecked` still delegated the facade checked scalar
helper through `sampleCheckedFrom(rng)`. The unchecked facade scalar path now
samples directly, so the checked facade can validate non-empty input first and
then call `sample(rng)` directly instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for character/string
sampling ergonomics. Alea exposes checked reusable ASCII charset scalar sampling;
this change tightens the checked facade path without changing byte selection,
empty validation, stream shape, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.sampleChecked` to reject empty charsets before
  entropy use, then call direct facade `sample(rng)`.
- `Charset.sampleCheckedFrom` remains unchanged for explicit direct-source
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
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M1097 is closed for the current bar: reusable ASCII `Charset.sampleChecked`
now avoids the direct-source checked wrapper alias while preserving stream shape,
empty validation, scalar byte output behavior, and singleton no-consume behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
