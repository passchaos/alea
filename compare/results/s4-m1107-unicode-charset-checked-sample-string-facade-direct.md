# S4-M1107 Unicode Charset Checked SampleString Facade Direct Path

## Gap

Reusable `UnicodeCharset.sampleStringChecked` still delegated the checked
allocation-returning facade UTF-8 string helper through
`sampleStringCheckedFrom(allocator, rng, ...)`. The direct facade UTF-8 string
path now allocates and encodes sampled scalars without `From` wrappers, so the
checked facade can validate and call that direct facade path instead of bouncing
through the direct-source checked string wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes checked reusable Unicode scalar charsets for
owned UTF-8 string generation, extending beyond Rust `rand` ASCII-centric string
helpers. This change tightens the checked owned Unicode charset facade path
without changing scalar selection, UTF-8 encoding, ownership, stream shape,
empty/invalid validation, zero-length behavior, or singleton no-consume
behavior.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.sampleStringChecked` to validate and
  call direct facade `sampleString`.
- `UnicodeCharset.sampleStringCheckedFrom` remains unchanged for explicit
  direct-source workflows.
- Existing validation and allocation-failure tests now cover the checked facade
  path directly.

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
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1107 is closed for the current bar: reusable
`UnicodeCharset.sampleStringChecked` now avoids the direct-source checked UTF-8
string wrapper alias while preserving stream shape, allocation ownership,
empty/invalid validation, zero-length behavior, UTF-8 encoding, and singleton
no-consume behavior. This is reliability / ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
