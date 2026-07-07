# S4-M660 Rng Duration Batch Invalid-Range Prevalidation

## Gap

Checked duration allocation-returning range batch helpers validate exclusive and
inclusive ranges before allocation. The unchecked batch helpers allocated first
and then called scalar duration range helpers that assert range validity, so
invalid non-zero requests could fail after allocation or via assertions.

Unchecked duration range batch helpers should reject invalid ranges before
allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes `UniformDuration` for `core::time::Duration`
in `src/distr/uniform_other.rs`. Its constructors reject invalid duration ranges
before sampling. Alea's duration API is Zig-native and supports signed
`std.Io.Duration`, but the same pre-sampling validation rule applies.

## API Changed

`src/rng.zig` now prevalidates invalid ranges in:

- `durationRangeLessThanBatchFrom`
- `durationRangeAtMostBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validation.
- Non-zero invalid exclusive duration ranges return `error.EmptyRange` before
  allocation and random-stream use.
- Non-zero invalid inclusive duration ranges return `error.EmptyRange` before
  allocation and random-stream use.
- Valid allocation failures remain no-stream.
- Valid random paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover invalid exclusive and inclusive duration batch requests
  before allocation and stream consumption, plus existing zero-count and valid
  allocation-failure no-stream behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "owned duration range batches allocate and validate before consuming random stream"
1/2 rng.test.owned duration range batches allocate and validate before consuming random stream...OK
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
toolingcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M660 is closed for the current bar: `Rng` unchecked duration range batch
helpers now reject invalid ranges before allocation, random-stream use, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
