# S4-M1105 ASCII Charset Checked SampleString Facade Direct Path

## Gap

Reusable ASCII `Charset.sampleStringChecked` still delegated the checked
allocation-returning facade string helper through `sampleStringCheckedFrom`.
The checked owned-byte facade now validates and allocates directly, so checked
string generation can call `allocChecked` directly instead of bouncing through
the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes checked reusable ASCII charset string helpers
layered on checked byte batches; this change tightens the facade string path
without changing byte selection, ownership, stream shape, empty validation, or
singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `Charset.sampleStringChecked` to call direct facade
  `allocChecked`.
- `Charset.sampleStringCheckedFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused ASCII charset tests:

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
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M1105 is closed for the current bar: reusable ASCII
`Charset.sampleStringChecked` now avoids the direct-source checked string wrapper
alias while preserving stream shape, allocation ownership, empty validation,
zero-length behavior, and singleton no-consume behavior. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
