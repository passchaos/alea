# S4-M18 Sequence Sampling Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for sequence and collection sampling APIs,
covering index sampling, item subsets, in-place partial shuffles, reservoir
sampling, reusable choices, and streaming iterator choices.

## Change

Added `examples/sequence_sampling.zig` and build step:

```sh
zig build run-sequence-sampling
```

The example demonstrates:

- `seq.sampleIndicesFrom` and compact `seq.sampleIndexVecFrom`;
- `seq.chooseMultipleFrom` and `Rng.sampleWithoutReplacementFrom` for item
  subsets;
- `seq.partialShuffleFrom` for in-place head selection;
- `seq.reservoirSampleFrom` for stream-like sampling;
- reusable `seq.Choice.fillValuesFrom`;
- `seq.chooseIteratorFrom` and `seq.sampleIteratorFrom` over a simple counter
  stream.

It prints deterministic output and a short decision guide for choosing the right
sequence helper.

## Validation

Command:

```sh
zig build run-sequence-sampling
```

Result: passed and printed deterministic sequence-sampling outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M18 Decision

S4-M18 is closed for the current sequence-sampling adoption bar: sequence and
collection sampling users now have runnable guidance in addition to API docs,
unit tests, and benchmark/parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
