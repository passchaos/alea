# S4-M132 Seq Repeated Choice Fill Aliases

Result: passed.

Purpose: make repeated with-replacement slice choices discoverable in the `seq`
namespace. Alea already had `Rng.fillChoose*` and reusable `Choice.fill*`; this
milestone adds `seq.fillChoose*` aliases for users coming from local Rust
`IndexedRandom::choose_iter(...).take(n)` workflows and for callers who want
caller-owned output buffers without constructing a reusable sampler.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose_iter(rng)` returns an iterator that samples from a
  slice with replacement;
- examples use `.take(n)` for repeated choices.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.fillChoose`;
- `seq.fillChooseFrom`;
- `seq.fillChooseChecked`;
- `seq.fillChooseCheckedFrom`;
- `seq.fillChooseConstPtr`;
- `seq.fillChooseConstPtrFrom`;
- `seq.fillChooseConstPtrChecked`;
- `seq.fillChooseConstPtrCheckedFrom`;
- `seq.fillChoosePtr`;
- `seq.fillChoosePtrFrom`;
- `seq.fillChoosePtrChecked`;
- `seq.fillChoosePtrCheckedFrom`.

These forward to existing `Rng.fillChoose*` helpers while using `seq`-style
`error.EmptyInput` in checked empty-input paths. Zero-length output buffers
return before validating item slices, and single-item slices fill deterministically
without consuming randomness.

Focused tests verify:

- facade/direct stream-shape parity against the existing `Rng` helpers;
- value, const-pointer, and mutable-pointer output buffers;
- zero-length checked no-consume behavior;
- checked empty-input no-consume behavior;
- singleton no-consume behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `seq.fillChooseFrom` and
  `seq.fillChooseConstPtrFrom` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the `seq.fillChoose` aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "seq choice"`
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
