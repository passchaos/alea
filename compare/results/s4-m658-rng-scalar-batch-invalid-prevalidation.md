# S4-M658 Rng Scalar Range/Probability Batch Invalid-Parameter Prevalidation

## Gap

Checked scalar range/probability allocation-returning batch helpers validate
parameters before allocation. The unchecked batch helpers allocated first and
then called fill helpers that assert parameter validity, so invalid non-zero
requests could fail after allocation or via assertions.

Unchecked scalar range/probability batch helpers should reject invalid parameters
before allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout remains the baseline comparison source for core
range and probability sampling. `RngExt::random_range` asserts non-empty ranges
before sampling, while `RngExt::random_bool` and `RngExt::random_ratio` construct
`Bernoulli` samplers and panic on invalid probabilities before sampling.

Alea keeps Zig-native error-returning allocation helpers rather than Rust panics.
S4-M658 applies the same pre-sampling validation discipline to unchecked scalar
batch helpers, returning errors before allocation and stream use.

## API Changed

`src/rng.zig` now prevalidates invalid parameters in:

- `rangeBatchFrom`
- `rangeAtMostBatchFrom`
- `uintLessThanBatchFrom`
- `chanceBatchFrom`
- `ratioBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validation.
- Non-zero invalid exclusive/inclusive/less-than ranges return
  `error.EmptyRange` before allocation and random-stream use.
- Non-zero non-finite float ranges return `error.NonFinite` before allocation and
  random-stream use.
- Non-zero invalid chance/ratio probabilities return `error.InvalidProbability`
  before allocation and random-stream use.
- Valid allocation failures remain no-stream.
- Valid random paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover invalid exclusive ranges, inclusive ranges,
  less-than bounds, non-finite float ranges, invalid chances, and invalid ratios
  before allocation and stream consumption, plus existing valid
  allocation-failure no-stream behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "owned range batches allocate and validate before consuming random stream"
1/2 rng.test.owned range batches allocate and validate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "owned bounded uint batches allocate and validate before consuming random stream"
1/2 rng.test.owned bounded uint batches allocate and validate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "owned probability batches allocate and validate before consuming random stream"
1/2 rng.test.owned probability batches allocate and validate before consuming random stream...OK
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
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M658 is closed for the current bar: `Rng` unchecked scalar range/probability
batch helpers now reject invalid parameters before allocation, random-stream use,
or assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
