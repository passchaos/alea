# S4-M134 Seq Index Choice Aliases

Result: passed.

Purpose: make with-replacement index choices discoverable in the `seq`
namespace alongside S4-M131 through S4-M133 value and pointer choice aliases.
Alea already had `Rng.chooseIndex*` and `Rng.chooseIndexU32*`; this milestone
adds `seq.chooseIndex*` aliases so index-first workflows do not need to leave the
sequence-sampling namespace.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose(rng)` selects a slice element by sampling a uniform
  index under the hood;
- `IndexedRandom::choose_iter(rng)` builds a `Uniform::new(0, self.len())`
  index distribution and maps sampled indexes back to slice references;
- examples use `.take(n)` for repeated with-replacement choices.

Rust exposes references for these slice APIs. Alea keeps the value/pointer
aliases from S4-M131 through S4-M133 and additionally exposes direct index
aliases, which are useful when callers want to sample positions first and map to
items later.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.chooseIndex`;
- `seq.chooseIndexFrom`;
- `seq.chooseIndexChecked`;
- `seq.chooseIndexCheckedFrom`;
- `seq.fillChooseIndex`;
- `seq.fillChooseIndexFrom`;
- `seq.fillChooseIndexChecked`;
- `seq.fillChooseIndexCheckedFrom`;
- `seq.chooseIndexBatch`;
- `seq.chooseIndexBatchFrom`;
- `seq.chooseIndexBatchChecked`;
- `seq.chooseIndexBatchCheckedFrom`;
- `seq.chooseIndexU32`;
- `seq.chooseIndexU32From`;
- `seq.chooseIndexU32Checked`;
- `seq.chooseIndexU32CheckedFrom`;
- `seq.fillChooseIndexU32`;
- `seq.fillChooseIndexU32From`;
- `seq.fillChooseIndexU32Checked`;
- `seq.fillChooseIndexU32CheckedFrom`;
- `seq.chooseIndexU32Batch`;
- `seq.chooseIndexU32BatchFrom`;
- `seq.chooseIndexU32BatchChecked`;
- `seq.chooseIndexU32BatchCheckedFrom`.

These forward to existing `Rng.chooseIndex*` helpers while using `seq`-style
`error.EmptyInput` for checked empty-length paths. Zero-length checked fills and
zero-count checked batches return before validating length and consume no
randomness; singleton lengths deterministically return/fill zero without
consuming randomness after allocation.

Focused tests verify:

- facade/direct stream-shape parity against the existing `Rng` helpers;
- one-shot, caller-owned fill, and allocation-returning batch outputs for
  `usize` and `u32` indexes;
- checked empty-input no-consume behavior using `error.EmptyInput`;
- zero-length fill and zero-count batch no-consume behavior;
- singleton no-consume behavior;
- allocation-failure no-consume behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `seq.chooseIndexFrom`,
  `seq.chooseIndexU32From`, `seq.fillChooseIndexFrom`,
  `seq.fillChooseIndexU32From`, `seq.chooseIndexBatchFrom`, and
  `seq.chooseIndexU32BatchFrom` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public `seq` symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the `seq.chooseIndex` aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "seq index choice"`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence API discoverability gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
