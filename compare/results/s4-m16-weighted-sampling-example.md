# S4-M16 Weighted Sampling Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for Alea's weighted sampling surfaces,
which are broad and easy to confuse without examples.

## Change

Added `examples/weighted_sampling.zig` and build step:

```sh
zig build run-weighted-sampling
```

The example demonstrates:

- one-shot `Rng.weightedIndexFrom`;
- static repeated `distributions.AliasTable` sampling plus probability export;
- dynamic `distributions.WeightedTree` update/push/sample workflows;
- integer-specialized `distributions.WeightedIntTree` update/sample workflows;
- item-oriented `seq.WeightedChoice` value fills;
- `seq.sampleWeightedFrom` and `seq.sampleWeightedIndicesFrom` for weighted
  no-replacement workflows.

The example prints deterministic sample output and a short decision guide:

- use one-shot weighted indexes for simple draws;
- use `AliasTable` for repeated static weights;
- use `WeightedTree` / `WeightedIntTree` for dynamic updates;
- use `seq` weighted helpers for item and no-replacement workflows.

## Validation

Command:

```sh
zig build run-weighted-sampling
```

Result: passed and printed deterministic weighted-sampling outputs.

`zig build examples` includes this example, so `zig build validate` now covers it
through the examples validation gate added in S4-M15.

## S4-M16 Decision

S4-M16 is closed for the current weighted-sampling adoption bar: weighted users
now have runnable guidance in addition to API docs, benchmarks, and parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
