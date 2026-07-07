# S4-M664 Rng Sample Batch Empty-Type Prevalidation

## Gap

`Rng.sampleBatchFrom` allocated its output buffer before validating uninhabited
output types. Non-zero sampler batch requests for empty enum-containing output
types should fail before allocation and before random-stream use.

This mirrors S4-M663 for `valueBatchFrom` and aligns with root `sampleBatch`
prevalidation.

## Local `rand` Baseline

The local Rust `rand` checkout exposes `Distribution<T>` / `sample_iter` for
supported output types. Rust's trait/type system prevents sampling unsupported or
uninhabited output combinations in the comparable APIs. Alea's Zig-native
sampler batches can name arbitrary output types, so empty enum-containing outputs
use the same `error.EmptyRange` validation policy as checked value helpers.

## API Changed

`src/rng.zig` now prevalidates empty enum-containing output types in:

- `sampleBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validating the output
  type.
- Non-zero empty enum-containing output types return `error.EmptyRange` before
  allocation and random-stream use.
- Habitable output types still allocate the output buffer and keep existing
  sampler stream shape.

## Adoption and Documentation

- Focused rng tests cover direct unchecked empty-enum and tuple-containing-empty
  enum sampler batch requests before allocation and stream consumption, plus
  zero-count behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "owned sampler batches validate empty output types before consuming random stream"
1/2 rng.test.owned sampler batches validate empty output types before consuming random stream...OK
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M664 is closed for the current bar: `Rng` unchecked sampler batch helpers now
reject non-zero empty enum-containing output types before allocation,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
