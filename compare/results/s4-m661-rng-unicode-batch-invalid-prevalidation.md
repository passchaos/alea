# S4-M661 Rng Unicode Scalar Range Batch Invalid-Parameter Prevalidation

## Gap

Checked Unicode scalar allocation-returning range batch helpers validate scalar
and range parameters before allocation. The unchecked batch helpers allocated
first and then called fill helpers that validate by `catch unreachable`, so
invalid non-zero requests could fail after allocation or via assertions.

Unchecked Unicode scalar range batch helpers should reject invalid scalar/range
parameters before allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes `UniformChar` for Unicode `char` ranges in
`src/distr/uniform_other.rs`. Its constructors validate ranges before sampling
and use a compressed scalar mapping to skip UTF-16 surrogate code points.

Alea uses Zig-native `u21` scalar helpers and supports explicit checked errors,
but follows the same pre-sampling validation rule for invalid scalars and empty
ranges.

## API Changed

`src/rng.zig` now prevalidates invalid scalar/range parameters in:

- `unicodeScalarRangeLessThanBatchFrom`
- `unicodeScalarRangeAtMostBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validation.
- Non-zero invalid Unicode scalar bounds return `error.InvalidParameter` before
  allocation and random-stream use.
- Non-zero empty Unicode scalar ranges return `error.EmptyRange` before
  allocation and random-stream use.
- Valid allocation failures remain no-stream.
- Valid random paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover invalid exclusive and inclusive Unicode scalar batch
  requests before allocation and stream consumption, plus existing zero-count and
  valid allocation-failure no-stream behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "owned unicode scalar range batches allocate and validate before consuming random stream"
1/2 rng.test.owned unicode scalar range batches allocate and validate before consuming random stream...OK
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
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M661 is closed for the current bar: `Rng` unchecked Unicode scalar range batch
helpers now reject invalid scalar/range parameters before allocation,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
