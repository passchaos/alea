# S4-M79 WeightedChoice Index Fills

Date: 2026-07-04

Purpose: add caller-owned index-buffer fills for reusable `WeightedChoice`.
Existing `WeightedChoice` could fill pointers and values for repeated weighted
choice; this adds direct index outputs for diagnostics, table reuse, and compact
index workflows.

## Change

Added reusable weighted-choice index fill helpers in `src/seq.zig`:

- `WeightedChoice.fillIndices(rng, dest)`;
- `WeightedChoice.fillIndicesFrom(source, dest)`;
- `WeightedChoice.fillIndicesU32(rng, dest)`;
- `WeightedChoice.fillIndicesU32From(source, dest)`.

`fillIndicesU32*` rejects item tables longer than `maxInt(u32)` before narrowing.
Single-positive alias tables fill deterministic indexes without consuming
randomness, matching existing pointer/value fill behavior.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints `weighted choice indices` and
  `weighted choice u32 indices` rows;
- `docs/examples.md` describes weighted choice value/index fills;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions weighted choice value/pointer/index fills;
- `tools/examplecheck.zig` guards the weighted example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M79 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- repeated weighted choice `usize` and `u32` index fills;
- zero-length fills do not consume randomness;
- single-positive fills do not consume randomness;
- index outputs avoid zero-weight items.

## S4-M79 Decision

S4-M79 is closed for the current reusable weighted-choice index-fill bar:
callers can now reuse a `WeightedChoice` table to fill caller-owned index buffers
without mapping through pointers or values.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
