# S4-M691 Rng Weighted Value Empty-Type Prevalidation

## Gap

Root and `seq` weighted value helpers now reject non-zero empty enum-containing
value types before allocation, entropy, or weighted sampling. `Rng` weighted
value-choice helpers could still validate weights, allocate output buffers, or
sample weighted indexes before reaching impossible value-copying paths for
uninhabited output types.

`Rng` weighted value-choice helpers should reject non-zero uninhabited value
types before allocation, random-stream use, weighted-index sampling, or value
copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes comparable weighted slice choice APIs via
`IndexedRandom::choose_weighted` / `sample_weighted` in `src/seq/slice.rs`,
backed by weighted-index sampling. Rust returns references over slice items and
ordinary use cannot construct impossible output values.

Alea's `Rng` value-returning weighted helpers can name empty enum-containing
value types, so `error.EmptyRange` is the deterministic pre-sampling validation
path for non-empty value outputs.

## API Changed

`src/rng.zig` now prevalidates empty enum-containing value types in weighted
value-choice helpers:

- `chooseWeightedFrom`
- `fillChooseWeightedFrom`
- `chooseWeightedValueArrayFrom`
- `chooseWeightedBatchFrom`
- `fillChooseWeightedCheckedFrom`
- `chooseWeightedValueArrayCheckedFrom`
- `chooseWeightedBatchCheckedFrom`

Pointer weighted-choice helpers are unchanged because they return addresses into
caller-owned slices instead of constructing values. Public signatures are
unchanged.

Deterministic behavior is explicit:

- Zero-output/zero-size/zero-count requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  output allocation, weighted-index validation/sampling, random-stream use, or
  value copying.
- Length mismatch and checked empty-weight validation keep existing precedence.
- Habitable value types keep existing weighted choice behavior and stream shape.

## Adoption and Documentation

- Focused rng tests cover scalar, optional fill, checked fill,
  allocation-returning, checked allocation-returning, optional fixed-array, and
  checked fixed-array weighted value-choice failures. Empty-type tests use a
  regular struct containing an empty enum field and avoid formatting impossible
  success values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "weighted value choices validate empty value types before sampling"
1/2 rng.test.weighted value choices validate empty value types before sampling...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "single-positive weighted index does not consume random stream"
1/2 rng.test.single-positive weighted index does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "invalid facade weighted helpers do not consume random stream"
1/2 rng.test.invalid facade weighted helpers do not consume random stream...OK
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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M691 is closed for the current bar: `Rng` weighted value-choice helpers now
reject non-zero empty enum-containing output types before allocation,
weighted-index sampling, random-stream use, value copying, or assertions. This
is reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
