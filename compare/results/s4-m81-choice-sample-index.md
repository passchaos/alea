# S4-M81 Choice Sampler Index Samples

Date: 2026-07-04

Purpose: add single-sample index outputs for reusable unweighted and weighted
choice samplers. This complements pointer/value samples and S4-M79/S4-M80
caller-owned index fills.

## Change

Added reusable-choice index sample helpers in `src/seq.zig`:

- `Choice.sampleIndex(rng)`;
- `Choice.sampleIndexFrom(source)`;
- `Choice.sampleIndexU32(rng)`;
- `Choice.sampleIndexU32From(source)`;
- `WeightedChoice.sampleIndex(rng)`;
- `WeightedChoice.sampleIndexFrom(source)`;
- `WeightedChoice.sampleIndexU32(rng)`;
- `WeightedChoice.sampleIndexU32From(source)`.

The `u32` forms reject item tables longer than `maxInt(u32)` before narrowing.
Single-item `Choice` and single-positive `WeightedChoice` paths return their
only possible index without consuming randomness.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `Choice.sampleIndexFrom`;
- `examples/weighted_sampling.zig` prints `weighted choice sample index` and
  `weighted choice sample u32 index`;
- `docs/examples.md` describes reusable choice value/index samples and fills;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions repeated choice value/index samples and fills;
- `tools/examplecheck.zig` guards the example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M81 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- reusable unweighted `usize` and `u32` index samples;
- reusable weighted `usize` and `u32` index samples;
- direct-source/facade parity through existing sampler flows;
- single-item/single-positive no-consume behavior.

## S4-M81 Decision

S4-M81 is closed for the current reusable choice index-sample bar: callers can
now sample a single index from `Choice` or `WeightedChoice` directly, without
mapping through a pointer/value sample or allocating/filling a buffer.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
