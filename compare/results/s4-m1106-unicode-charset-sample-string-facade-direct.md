# S4-M1106 Unicode Charset SampleString Facade Direct Path

## Gap

Reusable `UnicodeCharset.sampleString` still delegated the allocation-returning
facade UTF-8 string helper through `sampleStringFrom(allocator, rng, ...)`. The
facade helper can allocate, validate, and encode sampled scalars directly with
facade `Rng`, avoiding both the direct-source string wrapper and the facade
append wrapper while preserving the same UTF-8 output contract.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable Unicode scalar charsets for owned
UTF-8 string generation, extending beyond Rust `rand` ASCII-centric string
helpers. This change tightens the owned Unicode charset facade path without
changing scalar selection, UTF-8 encoding, ownership, stream shape, empty/invalid
validation, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.sampleString` to allocate capacity,
  validate, and encode sampled scalars directly through facade `Rng`.
- `UnicodeCharset.sampleStringFrom` remains unchanged for explicit direct-source
  workflows.
- Existing string validation and singleton stream-shape tests now cover the
  facade `sampleString` path directly.

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
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M1106 is closed for the current bar: reusable `UnicodeCharset.sampleString`
now avoids the direct-source UTF-8 string wrapper alias while preserving stream
shape, allocation ownership, empty/invalid validation, zero-length behavior,
UTF-8 encoding, and singleton no-consume behavior. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
