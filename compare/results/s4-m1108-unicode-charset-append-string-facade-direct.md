# S4-M1108 Unicode Charset AppendString Facade Direct Path

## Gap

Reusable `UnicodeCharset.appendString` still delegated the facade caller-owned
UTF-8 append helper through `appendStringFrom(allocator, rng, ...)`. The
direct-source append path already validates, reserves UTF-8 capacity, and
encodes sampled scalars into the caller-owned buffer. The facade helper can do
the same work directly with facade `Rng` instead of bouncing through the `From`
wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable Unicode scalar charsets and
caller-owned UTF-8 append generation, extending beyond Rust `rand` ASCII-centric
string helpers. This change tightens the Unicode charset append facade without
changing scalar selection, UTF-8 encoding, caller-owned output behavior, stream
shape, empty/invalid validation, zero-length behavior, or singleton no-consume
behavior.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.appendString` to validate, reserve,
  and encode sampled scalars directly through facade `Rng`.
- `UnicodeCharset.appendStringFrom` remains unchanged for explicit direct-source
  workflows.
- Existing validation, allocation-failure, stream-shape, and singleton tests now
  cover the facade append path directly.

## Validation

Focused Unicode charset tests:

```text
$ zig test src/ascii.zig --test-filter "unicode charset helpers preserve direct stream shape"
1/2 ascii.test.unicode charset helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode charset unchecked strings validate before allocation"
1/2 ascii.test.unicode charset unchecked strings validate before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "single-scalar unicode charset helpers do not consume random stream"
1/2 ascii.test.single-scalar unicode charset helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "initial unicode charset allocation failures do not consume random stream"
1/2 ascii.test.initial unicode charset allocation failures do not consume random stream...OK
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
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1108 is closed for the current bar: reusable `UnicodeCharset.appendString`
now avoids the direct-source UTF-8 append wrapper alias while preserving stream
shape, caller-owned output behavior, empty/invalid validation, zero-length
behavior, UTF-8 encoding, and singleton no-consume behavior. This is reliability
/ ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
