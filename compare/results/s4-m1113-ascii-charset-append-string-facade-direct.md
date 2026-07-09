# S4-M1113 ASCII Charset AppendString Facade Direct Path

## Gap

Reusable ASCII `Charset.appendString` still delegated the facade caller-owned
string append helper through `appendStringFrom(allocator, rng, ...)`. The
reusable ASCII `Charset.fill` facade now fills through facade `Rng` directly, so
append can reserve caller-owned output and fill the new tail directly instead of
bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable ASCII charset append helpers for
caller-owned string buffers, avoiding repeated allocation in high-volume string
workflows. This change tightens the ASCII charset append facade without changing
byte selection, caller-owned output behavior, stream shape, empty validation,
zero-length behavior, allocation-failure behavior, or singleton no-consume
behavior.

## Implementation

- `src/ascii.zig` updates `Charset.appendString` to validate, resize, and fill
  the appended tail through facade `fill` directly.
- `Charset.appendStringFrom` remains unchanged for explicit direct-source
  workflows.
- Existing stream-shape, empty-validation, and singleton tests now cover the
  facade append path directly.

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
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M1113 is closed for the current bar: reusable ASCII `Charset.appendString` now
avoids the `appendStringFrom` direct-source wrapper alias while preserving stream
shape, caller-owned output behavior, empty validation, zero-length behavior,
allocation-failure no-consume behavior, and singleton no-consume behavior. This
is reliability / ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
