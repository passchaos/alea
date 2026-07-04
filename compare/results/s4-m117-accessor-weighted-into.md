# S4-M117 Accessor-Based Weighted Caller-Owned Buffers

Result: passed.

Purpose: extend S4-M116's accessor-based weighted no-replacement samples to
caller-owned buffers. Local Rust `sample_weighted(&mut rng, amount, |item| ...)`
returns an iterator over references; Alea already exceeded that with
allocation-returning value/const-pointer/mutable-pointer forms. This milestone
adds allocation-free Zig-native buffer forms for users who want predictable
storage while keeping weights inside item records.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs` and
`/home/passchaos/Work/rand/src/seq/index.rs`:

- `IndexedRandom::sample_weighted(&mut rng, amount, |item| ...)` maps item
  accessors to index sampling;
- examples fill caller buffers by iterating sampled references;
- Rust's low-level `index::sample_weighted` exposes index sampling from an index
  weight closure.

## Alea API Added

`src/seq.zig` now exposes caller-owned accessor-weighted no-replacement helpers:

- `seq.sampleWeightedIndicesByInto` /
  `seq.sampleWeightedIndicesByIntoFrom`;
- `seq.sampleWeightedIndicesByIntoChecked` /
  `seq.sampleWeightedIndicesByIntoCheckedFrom`;
- `seq.sampleWeightedByInto` / `seq.sampleWeightedByIntoFrom`;
- `seq.sampleWeightedByIntoChecked` /
  `seq.sampleWeightedByIntoCheckedFrom`;
- `seq.sampleWeightedPtrsByInto` / `seq.sampleWeightedPtrsByIntoFrom`;
- `seq.sampleWeightedPtrsByIntoChecked` /
  `seq.sampleWeightedPtrsByIntoCheckedFrom`;
- `seq.sampleWeightedMutPtrsByInto` /
  `seq.sampleWeightedMutPtrsByIntoFrom`;
- `seq.sampleWeightedMutPtrsByIntoChecked` /
  `seq.sampleWeightedMutPtrsByIntoCheckedFrom`.

Optional forms fill as many positive-weight items as available and return the
filled count. Checked forms require enough positive-weight items. Zero-count
calls return before validating weights. Invalid weights, empty positive sets for
checked calls, length-mismatched scratch buffers, and invalid counts return
before drawing. Single-positive accessors fill one deterministic item/index or
pointer without consuming random stream state.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints:
  - `weighted by indices into`
  - `weighted by values into`
  - `weighted by ptrs into`
  - `weighted by mut ptrs into scores`
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the caller-owned accessor-weighted workflows.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig build test`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence ergonomics/storage gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
