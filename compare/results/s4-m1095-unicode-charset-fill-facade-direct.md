# S4-M1095 Unicode Charset Fill Facade Direct Path

## Gap

Reusable `UnicodeCharset.fill` still delegated the facade scalar-fill helper
through `fillFrom(rng, ...)`. The direct-source path already fills scalars by
sampling indexes directly from the Unicode scalar set, so the facade helper can
perform the same loop with facade `Rng` instead of bouncing through the `From`
wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for string/character
sampling ergonomics. Alea exposes reusable Unicode scalar charsets for
allocation-returning and caller-owned UTF-8/scalar generation; this change
tightens the caller-owned scalar fill facade path without changing scalar
selection, stream shape, validation, or singleton no-consume behavior.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.fill` to preserve singleton `@memset`
  behavior and sample scalar indexes directly through facade `Rng`.
- `UnicodeCharset.fillFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused Unicode charset tests:

```text
$ zig test src/ascii.zig --test-filter "unicode charset helpers preserve direct stream shape"
1/2 ascii.test.unicode charset helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "unicode charset strings sample from scalar choices"
1/2 ascii.test.unicode charset strings sample from scalar choices...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/ascii.zig --test-filter "single-scalar unicode charset helpers do not consume random stream"
1/2 ascii.test.single-scalar unicode charset helpers do not consume random stream...OK
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
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1095 is closed for the current bar: reusable `UnicodeCharset.fill` now avoids
the direct-source wrapper alias while preserving stream shape, caller-owned
output behavior, validation assumptions, and singleton no-consume behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
