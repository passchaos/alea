# S4-M1104 ASCII Charset SampleString Facade Direct Path

## Gap

Reusable ASCII `Charset.sampleString` still delegated the allocation-returning
facade string helper through `sampleStringFrom(allocator, rng, ...)`. The owned
byte facade path now allocates and fills directly, so `sampleString` can call
`alloc` directly instead of bouncing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable ASCII charset string helpers layered
on byte batches; this change tightens the facade string path without changing
byte selection, ownership, stream shape, empty validation, or singleton
no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.sampleString` to call direct facade `alloc`.
- `Charset.sampleStringFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused ASCII charset tests:

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
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M1104 is closed for the current bar: reusable ASCII `Charset.sampleString` now
avoids the direct-source string wrapper alias while preserving stream shape,
allocation ownership, empty validation, zero-length behavior, and singleton
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
