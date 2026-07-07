# S4-M689 Seq Accessor-Weighted Sample Empty-Type Prevalidation

## Gap

Parallel-weighted no-replacement value samples now reject non-zero uninhabited
value types before allocation and random-stream use. The item-accessor weighted
no-replacement value sample helpers could still evaluate accessor weights,
allocate output/index buffers, generate weighted sampling keys, or copy values
before reaching impossible value paths for empty enum-containing value types.

`seq` item-accessor weighted no-replacement value sample helpers should reject
non-zero uninhabited value types before accessor weight evaluation, allocation,
random-stream use, weighted-key sampling, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes comparable accessor-weighted
no-replacement sampling through `IndexedRandom::sample_weighted` in
`src/seq/slice.rs`, backed by `index::sample_weighted` in `src/seq/index.rs`.
Rust returns references over slice items and normal use cannot construct or clone
impossible value types.

Alea's Zig-native accessor-weighted value-returning helpers can name empty
enum-containing value types, so `error.EmptyInput` is the deterministic
pre-sampling validation path for non-zero value outputs.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in
item-accessor weighted no-replacement value sample helpers:

- `sampleWeightedByFrom`
- `sampleWeightedByCheckedFrom`
- `sampleWeightedByIntoFrom`
- `sampleWeightedByIntoCheckedFrom`
- `sampleWeightedArrayByFrom`
- `sampleWeightedArrayByCheckedFrom`

Pointer accessor-weighted sample helpers are unchanged because they return
addresses into caller-owned slices instead of constructing values. Public
signatures are unchanged.

Deterministic behavior is explicit:

- Zero-amount/zero-output/zero-size requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  accessor weight evaluation, output allocation, index allocation,
  weighted-key sampling, random-stream use, or value copying.
- Checked oversized requests keep `error.InvalidParameter` precedence.
- Habitable value types keep existing accessor-weighted no-replacement behavior
  and stream shape.

## Adoption and Documentation

- Focused seq tests cover allocation-returning, checked allocation-returning,
  caller-owned, checked caller-owned, optional fixed-array, and checked
  fixed-array accessor-weighted no-replacement value failures. Empty-type tests
  use a regular struct containing an empty enum field and avoid formatting
  impossible success values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "accessor weighted no-replacement samples allocate values and pointers"
1/2 seq.test.accessor weighted no-replacement samples allocate values and pointers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "accessor weighted caller-owned buffers fill values indexes and pointers"
1/2 seq.test.accessor weighted caller-owned buffers fill values indexes and pointers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "accessor weighted item arrays return fixed-size values and pointers"
1/2 seq.test.accessor weighted item arrays return fixed-size values and pointers...OK
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
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M689 is closed for the current bar: `seq` item-accessor weighted
no-replacement value sample helpers now reject non-zero empty enum-containing
value types before accessor evaluation, allocation, random-stream use,
weighted-key sampling, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
