# S4-M1112 ASCII SampleString Facade Direct Path

## Gap

Top-level `ascii.sampleString` still delegated the facade alphanumeric owned-byte
helper through `sampleStringFrom(allocator, rng, ...)`. The reusable ASCII
`Charset.sampleString` facade now calls the direct allocation facade, so the
top-level convenience helper can call that facade instead of bouncing through
the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes top-level alphanumeric sample string helpers
for common password/identifier-style workflows. This change tightens the
top-level ASCII sampleString facade path without changing byte selection,
allocation ownership, stream shape, zero-length behavior, allocation-failure
behavior, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates top-level `sampleString` to call
  `Alphanumeric.sampleString` directly.
- `sampleStringFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused ASCII tests:

```text
$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "zero-length string helpers do not consume random stream"
1/2 ascii.test.zero-length string helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "initial string allocation failures do not consume random stream"
1/2 ascii.test.initial string allocation failures do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "single-byte charset helpers do not consume random stream"
1/2 ascii.test.single-byte charset helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M1112 is closed for the current bar: top-level `ascii.sampleString` now avoids
the `sampleStringFrom` direct-source wrapper alias while preserving stream shape,
allocation ownership, zero-length behavior, allocation-failure no-consume
behavior, and alphanumeric sampling behavior. This is reliability / ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
