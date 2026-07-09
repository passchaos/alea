# S4-M1096 ASCII Charset Sample Facade Direct Path

## Gap

Reusable ASCII `Charset.sample` still delegated the facade scalar-byte helper
through `sampleFrom(rng)`. The direct-source path already samples a charset index
directly, so the facade helper can perform the same selection with facade `Rng`
instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for character/string
sampling ergonomics. Alea exposes reusable ASCII charsets for scalar and bulk
byte/string generation; this change tightens the scalar facade sample path
without changing byte selection, stream shape, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.sample` to preserve singleton behavior and
  sample charset indexes directly through facade `Rng`.
- `Charset.sampleFrom` remains unchanged for explicit direct-source workflows.

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

$ zig test src/ascii.zig --test-filter "ascii charset fills requested length"
1/2 ascii.test.ascii charset fills requested length...OK
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
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M1096 is closed for the current bar: reusable ASCII `Charset.sample` now avoids
the direct-source wrapper alias while preserving stream shape, scalar byte output
behavior, and singleton no-consume behavior. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
