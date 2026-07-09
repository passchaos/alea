# S4-M1102 ASCII Charset Alloc Facade Direct Path

## Gap

Reusable ASCII `Charset.alloc` still delegated the allocation-returning facade
byte batch helper through `allocFrom(allocator, rng, ...)`. The caller-owned
facade fill path now samples directly, so the allocation-returning facade can
allocate and fill through `fill(rng, ...)` directly instead of bouncing through
the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable ASCII charsets for allocation-returning
byte/string generation; this change tightens the allocation-returning facade path
without changing byte selection, ownership, stream shape, empty validation, or
singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.alloc` to handle zero length, reject empty
  charsets before allocation/entropy use, allocate the output, and fill it
  through direct facade `fill(rng, out)`.
- `Charset.allocFrom` remains unchanged for explicit direct-source workflows.

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
readmecheck ok
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M1102 is closed for the current bar: reusable ASCII `Charset.alloc` now avoids
the direct-source allocation wrapper alias while preserving stream shape,
allocation ownership, empty validation, zero-length behavior, and singleton
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
