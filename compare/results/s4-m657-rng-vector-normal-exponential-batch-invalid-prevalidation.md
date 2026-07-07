# S4-M657 Rng Vector Normal/Exponential Batch Invalid-Parameter Prevalidation

## Gap

S4-M656 tightened scalar normal/exponential allocation-returning batch helpers so
invalid parameters fail before allocation. Vector normal and exponential
unchecked batch helpers still allocated output buffers before calling fill helpers
that assert parameter validity.

Unchecked vector normal/exponential batch helpers should reject invalid parameters
before allocation and before random-stream use.

## Local `rand_distr` Baseline

The local Rust `rand_distr` checkout remains the baseline comparison source for
normal/exponential distributions. Its constructors validate invalid standard
deviation or rate parameters before sampling. Alea's checked vector batch helpers
already model that behavior; S4-M657 applies it to unchecked vector
allocation-returning batch helpers.

## API Changed

`src/rng.zig` now prevalidates invalid parameters in:

- `vectorNormalBatchFrom`
- `vectorExponentialBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validation.
- Non-zero invalid vector normal/exponential parameters return
  `error.InvalidParameter` before allocation and random-stream use.
- Valid allocation failures remain no-stream.
- Valid random paths keep existing stream shape.

## Adoption and Documentation

- Focused rng tests cover invalid vector normal/exponential batch requests before
  allocation and stream consumption, plus existing valid allocation-failure
  no-stream behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "owned vector normal and exponential batches"
1/2 rng.test.owned vector normal and exponential batches allocate and validate before consuming random stream...OK
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
roadmapcheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M657 is closed for the current bar: `Rng` unchecked vector normal/exponential
batch helpers now reject invalid parameters before allocation, random-stream use,
or assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
