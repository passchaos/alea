# S4-M659 Rng Vector Range/Probability Batch Invalid-Parameter Prevalidation

## Gap

S4-M658 tightened scalar range/probability allocation-returning batch helpers so
invalid parameters fail before allocation. Vector range and probability unchecked
batch helpers still allocated output buffers before calling fill helpers that
assert parameter validity.

Unchecked vector range/probability batch helpers should reject invalid parameters
before allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout remains the baseline comparison source for core
range and probability sampling. `RngExt::random_range` asserts non-empty ranges
before sampling, while `RngExt::random_bool` and `RngExt::random_ratio` construct
`Bernoulli` samplers and panic on invalid probabilities before sampling.

Rust `rand` does not expose Alea's Zig-native vector batch API shape, but the
same pre-sampling validation rule applies: invalid vector range/probability
batch parameters should fail deterministically before allocation or random-stream
use.

## API Changed

`src/rng.zig` now prevalidates invalid parameters in:

- `vectorRangeBatchFrom`
- `vectorRangeAtMostBatchFrom`
- `vectorChanceBatchFrom`
- `vectorRatioBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validation.
- Non-zero invalid vector exclusive/inclusive ranges return `error.EmptyRange`
  before allocation and random-stream use.
- Non-zero non-finite vector float ranges return `error.NonFinite` before
  allocation and random-stream use.
- Non-zero invalid vector chance/ratio probabilities return
  `error.InvalidProbability` before allocation and random-stream use.
- Valid allocation failures remain no-stream.
- Valid random paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover invalid vector exclusive ranges, inclusive ranges,
  non-finite float ranges, invalid chances, and invalid ratios before allocation
  and stream consumption, plus existing valid allocation-failure no-stream
  behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "owned vector range batches allocate and validate before consuming random stream"
1/2 rng.test.owned vector range batches allocate and validate before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "owned vector probability batches allocate and validate before consuming random stream"
1/2 rng.test.owned vector probability batches allocate and validate before consuming random stream...OK
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
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M659 is closed for the current bar: `Rng` unchecked vector range/probability
batch helpers now reject invalid parameters before allocation, random-stream use,
or assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
