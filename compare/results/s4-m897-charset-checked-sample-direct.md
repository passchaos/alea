# S4-M897 Charset Checked Sample Direct Index Paths

## Gap

`Charset.sampleCheckedFrom` and `UnicodeCharset.sampleCheckedFrom` still routed
valid checked samples through their unchecked `sampleFrom` wrappers after
prevalidation, adding a wrapper before the uniform-index-to-item mapping.

## Local `rand` Baseline

Local `rand` charset/string workflows sample indexes into a chosen character set.
Alea's checked charset APIs first validate empty/invalid inputs, then share the
same uniform-index mapping as unchecked sampling. After prevalidation succeeds,
checked samples can draw the index and map into storage directly while preserving
stream shape and checked error behavior.

## Implementation

- `src/ascii.zig` updates ASCII `Charset.sampleCheckedFrom` to keep empty-charset
  prevalidation and then directly execute singleton or uniform-index byte mapping.
- `src/ascii.zig` updates `UnicodeCharset.sampleCheckedFrom` to keep
  empty/invalid scalar prevalidation and then directly execute singleton or
  uniform-index scalar mapping.
- Focused tests compare checked facade/direct stream shape for ASCII and Unicode
  charsets; existing tests still cover empty/invalid no-consume behavior.

## Validation

Focused ASCII tests:

```text
$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode charset helpers preserve direct stream shape"
1/2 ascii.test.unicode charset helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M897 is closed for the current bar: ASCII and Unicode charset checked samples
now avoid unchecked sampling wrappers while preserving stream shape and checked
prevalidation behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
