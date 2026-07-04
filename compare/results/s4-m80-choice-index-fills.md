# S4-M80 Choice Index Fills

Date: 2026-07-04

Purpose: add caller-owned index-buffer fills for reusable unweighted `Choice`.
Existing `Choice` could fill pointers and values for repeated choices; this adds
direct `usize` and `u32` index outputs, mirroring S4-M79's `WeightedChoice` index
fills.

## Change

Added reusable choice index fill helpers in `src/seq.zig`:

- `Choice.fillIndices(rng, dest)`;
- `Choice.fillIndicesFrom(source, dest)`;
- `Choice.fillIndicesU32(rng, dest)`;
- `Choice.fillIndicesU32From(source, dest)`.

`fillIndicesU32*` rejects item slices longer than `maxInt(u32)` before narrowing.
Single-item choices fill deterministic index `0` without consuming randomness,
matching existing pointer/value fill behavior.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `Choice.fillIndicesFrom` and
  `Choice.fillIndicesU32From` rows;
- `docs/examples.md` describes reusable choice value/index fills;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions repeated choice value/index fills;
- `tools/examplecheck.zig` guards the sequence example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M80 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- repeated choice `usize` and `u32` index fills;
- zero-length fills do not consume randomness;
- single-item fills do not consume randomness;
- index outputs stay within item bounds.

## S4-M80 Decision

S4-M80 is closed for the current reusable unweighted choice index-fill bar:
callers can now reuse a `Choice` sampler to fill caller-owned index buffers
without mapping through pointers or values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
