# S4-M1115 ASCII AppendString Facade Direct Path

## Gap

Top-level `ascii.appendString` still delegated the facade alphanumeric
caller-owned append helper through `appendStringFrom(allocator, rng, ...)`. The
reusable ASCII `Charset.appendString` facade now resizes and fills through
facade `Rng` directly, so the top-level convenience helper can call that facade
instead of bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes top-level alphanumeric append helpers for
caller-owned string buffers, avoiding repeated allocation in common
password/identifier workflows. This change tightens the top-level ASCII append
facade path without changing byte selection, caller-owned output behavior,
stream shape, empty validation, zero-length behavior, allocation-failure
behavior, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates top-level `appendString` to call
  `Alphanumeric.appendString` directly.
- `appendStringFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused ASCII tests:

```text
$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "sampleString unchecked aliases handle empty charsets before allocation"
1/2 ascii.test.sampleString unchecked aliases handle empty charsets before allocation...OK
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
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1115 is closed for the current bar: top-level `ascii.appendString` now avoids
the `appendStringFrom` direct-source wrapper alias while preserving stream shape,
caller-owned output behavior, empty validation, zero-length behavior,
allocation-failure no-consume behavior, and alphanumeric sampling behavior. This
is reliability / ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
