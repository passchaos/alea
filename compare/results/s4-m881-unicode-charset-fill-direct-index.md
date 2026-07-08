# S4-M881 UnicodeCharset Reusable Fill Direct Index Sampling

## Gap

Reusable `ascii.UnicodeCharset.fillFrom` still routed every non-singleton scalar
through `UnicodeCharset.sampleFrom`, adding a wrapper call before drawing a
uniform index and mapping into the scalar slice.

## Local `rand` Baseline

Local `rand` string/charset workflows ultimately sample indexes into a chosen
character set. Alea's `UnicodeCharset` stores the scalar slice directly and uses
uniform index sampling for non-singleton sets, so reusable scalar fills can
generate the index and map to the scalar slice directly while preserving the same
stream as repeated `UnicodeCharset.sampleFrom` calls.

## Implementation

- `src/ascii.zig` updates `UnicodeCharset.fillFrom` to keep the singleton
  no-consume path, then draw indexes directly with `Rng.uintLessThanFrom` and map
  into `self.scalars` instead of calling `UnicodeCharset.sampleFrom` for every
  scalar.
- Focused tests compare `UnicodeCharset.fillFrom` with a
  `UnicodeCharset.sampleFrom` loop under identical seeds; existing focused
  coverage still checks singleton no-consume behavior and checked empty/invalid
  scalar sets.

## Validation

Focused ASCII test:

```text
$ zig test src/ascii.zig --test-filter "unicode charset helpers preserve direct stream shape"
1/2 ascii.test.unicode charset helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M881 is closed for the current bar: reusable `UnicodeCharset.fillFrom` now
avoids per-scalar `UnicodeCharset.sampleFrom` wrapper calls for non-singleton
fills while preserving stream shape and singleton no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
