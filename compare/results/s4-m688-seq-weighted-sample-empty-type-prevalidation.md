# S4-M688 Seq Weighted Sample Empty-Type Prevalidation

## Gap

Root parallel-weight value-choice helpers and `Rng` empty-type detection now
reject uninhabited value types before allocation or entropy. The `seq`
parallel-weighted no-replacement value sample helpers could still validate
weights, allocate output/index buffers, generate weighted sampling keys, or copy
values before reaching impossible value paths for empty enum-containing value
types.

`seq` parallel-weighted no-replacement value sample helpers should reject
non-zero uninhabited value types before allocation, random-stream use,
weighted-key sampling, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes comparable weighted no-replacement
sampling via `IndexedRandom::sample_weighted` in `src/seq/slice.rs`, backed by
`index::sample_weighted` in `src/seq/index.rs`. Rust's value/reference typing
rules prevent constructing or cloning impossible value types in normal use, and
its weighted sampler returns references over slice items.

Alea's Zig-native value-returning helpers can name empty enum-containing value
types, so `error.EmptyInput` is the deterministic pre-sampling validation path
for non-zero value outputs.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in the
parallel-weighted no-replacement value sample helpers:

- `sampleWeightedFrom`
- `sampleWeightedCheckedFrom`
- `sampleWeightedIntoFrom`
- `sampleWeightedIntoCheckedFrom`
- `sampleWeightedArrayFrom`
- `sampleWeightedArrayCheckedFrom`

Pointer weighted sample helpers are unchanged because they return addresses into
caller-owned slices instead of constructing values. Public signatures are
unchanged.

Deterministic behavior is explicit:

- Zero-amount/zero-output/zero-size requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  output allocation, index allocation, weighted-key sampling, random-stream use,
  or value copying.
- Length-mismatch and empty-input shape validation keeps existing precedence.
- Habitable value types keep existing weighted no-replacement behavior and
  stream shape.

## Adoption and Documentation

- Focused seq tests cover allocation-returning, checked allocation-returning,
  caller-owned, checked caller-owned, optional fixed-array, and checked
  fixed-array weighted no-replacement value failures. Empty-type tests use a
  regular struct containing an empty enum field and avoid formatting impossible
  success values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "weighted no-replacement samples produce support and validate inputs"
1/2 seq.test.weighted no-replacement samples produce support and validate inputs...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "sampleWeightedInto fills caller-owned item buffers"
1/2 seq.test.sampleWeightedInto fills caller-owned item buffers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "sampleWeightedArray validates empty value types before sampling"
1/2 seq.test.sampleWeightedArray validates empty value types before sampling...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "sampleWeightedArray preserves facade/direct stream shape and invalid paths do not consume"
1/2 seq.test.sampleWeightedArray preserves facade/direct stream shape and invalid paths do not consume...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M688 is closed for the current bar: `seq` parallel-weighted
no-replacement value sample helpers now reject non-zero empty enum-containing
value types before allocation, random-stream use, weighted-key sampling, value
copying, or assertions. This is reliability and ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
