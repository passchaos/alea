# S4-M1094 ASCII Charset Fill Facade Direct Path

## Gap

Reusable ASCII `Charset.fill` still delegated the facade byte-fill helper through
`fillFrom(rng, ...)`. The direct-source path already fills bytes by sampling
indexes directly from the charset, so the facade helper can perform the same loop
with facade `Rng` instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable ASCII charsets for allocation-returning
and caller-owned byte/string generation; this change tightens the caller-owned
facade fill path without changing byte selection, stream shape, or singleton
no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.fill` to preserve singleton `@memset`
  behavior and sample charset indexes directly through facade `Rng`.
- `Charset.fillFrom` remains unchanged for explicit direct-source workflows.

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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1094 is closed for the current bar: reusable ASCII `Charset.fill` now avoids
the direct-source wrapper alias while preserving stream shape, caller-owned
output behavior, and singleton no-consume behavior. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
