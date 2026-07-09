# S4-M1114 ASCII Charset Checked AppendString Facade Direct Path

## Gap

Reusable ASCII `Charset.appendStringChecked` still delegated the checked facade
caller-owned string append helper through `appendStringCheckedFrom(allocator,
rng, ...)`. The reusable ASCII `Charset.appendString` facade now validates,
resizes, and fills the appended tail without `From` wrappers, so the checked
facade can validate and call that direct facade path instead of bouncing through
the direct-source checked append wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes checked reusable ASCII charset append helpers
for caller-owned string buffers, avoiding repeated allocation in high-volume
string workflows. This change tightens the checked ASCII charset append facade
without changing byte selection, caller-owned output behavior, stream shape,
empty validation, zero-length behavior, allocation-failure behavior, or singleton
no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.appendStringChecked` to validate and call the
  direct facade `appendString`.
- `Charset.appendStringCheckedFrom` remains unchanged for explicit direct-source
  workflows.
- Existing stream-shape, empty-validation, and singleton tests now cover the
  checked facade append path directly.

## Validation

Focused ASCII tests:

```text
$ zig test src/ascii.zig --test-filter "ascii helpers preserve direct stream shape"
1/2 ascii.test.ascii helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "sampleString checked aliases handle empty charsets without consuming"
1/2 ascii.test.sampleString checked aliases handle empty charsets without consuming...OK
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
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M1114 is closed for the current bar: reusable ASCII
`Charset.appendStringChecked` now avoids the `appendStringCheckedFrom`
direct-source wrapper alias while preserving stream shape, caller-owned output
behavior, empty validation, zero-length behavior, allocation-failure no-consume
behavior, and singleton no-consume behavior. This is reliability / ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
