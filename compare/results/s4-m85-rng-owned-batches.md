# S4-M85 Rng Owned Repeated Samples

Date: 2026-07-04

Purpose: add allocation-returning repeated value and sampler batches for `Rng`.
This complements `valueIter`, `sampleIter`, caller-owned `fill`, and
caller-owned `fillSample` workflows with an owned-slice form for callers who do
not want to manage the output buffer themselves.

## Change

Added owned repeated-value helpers in `src/rng.zig`:

- `Rng.valueBatch(T, allocator, count)`;
- `Rng.valueBatchFrom(source, T, allocator, count)`;
- `Rng.valueBatchChecked(T, allocator, count)`;
- `Rng.valueBatchCheckedFrom(source, T, allocator, count)`.

Added owned sampler-draw helpers in `src/rng.zig`:

- `Rng.sampleBatch(T, allocator, sampler, count)`;
- `Rng.sampleBatchFrom(source, T, allocator, sampler, count)`.

The checked value-batch helpers preserve the existing empty-enum policy:
zero-count requests allocate an empty slice without validating the sampled type,
while positive counts reject empty enum-containing value types before consuming
randomness.

Updated adoption/docs:

- `examples/basic.zig` prints `valueBatch u16` and `sampleBatch dice` rows;
- `docs/examples.md` describes owned value/sample batches in the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions `Rng.valueBatch`, `Rng.valueBatchChecked`, and
  `Rng.sampleBatch`;
- `tools/examplecheck.zig` guards the basic example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M85 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- facade/direct stream-shape parity for `valueBatch` and `sampleBatch`;
- allocation-failure paths without stream consumption;
- checked empty-enum no-consume behavior for positive counts;
- zero-count checked value batches returning before empty-enum validation or
  allocation failure.

## S4-M85 Decision

S4-M85 is closed for the current `Rng` owned repeated-sample bar: callers can now
request owned repeated values or sampler draws without spelling an iterator loop
or caller-owned buffer.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
