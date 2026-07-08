# S4-M880 ASCII Charset Reusable Fill Direct Index Sampling

## Gap

Reusable `ascii.Charset.fillFrom` still routed every non-singleton output byte
through `Charset.sampleFrom`, adding a wrapper call before drawing a uniform
index and mapping into the byte slice.

## Local `rand` Baseline

Local `rand` string/charset generation ultimately samples indexes into a chosen
character set. Alea's `Charset` stores the byte slice directly and uses uniform
index sampling for non-singleton sets, so reusable byte fills can generate the
index and map to the byte slice directly while preserving the same stream as
repeated `Charset.sampleFrom` calls.

## Implementation

- `src/ascii.zig` updates `Charset.fillFrom` to keep the singleton no-consume
  path, then draw indexes directly with `Rng.uintLessThanFrom` and map into
  `self.bytes` instead of calling `Charset.sampleFrom` for every byte.
- Focused tests compare `Alphanumeric.fillFrom` with a `Charset.sampleFrom` loop
  under identical seeds; existing focused coverage still checks singleton
  no-consume behavior and checked empty-charsets.

## Validation

Focused ASCII test:

```text
$ zig test src/ascii.zig --test-filter "ascii charset fills requested length"
1/2 ascii.test.ascii charset fills requested length...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M880 is closed for the current bar: reusable `Charset.fillFrom` now avoids
per-byte `Charset.sampleFrom` wrapper calls for non-singleton fills while
preserving stream shape and singleton no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
