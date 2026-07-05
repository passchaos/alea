# S4-M229 Uniform sampleSingle Aliases

Result: passed.

Purpose: add Rust-discoverable one-shot checked uniform range aliases. Local
Rust `UniformSampler` exposes `sample_single` and `sample_single_inclusive` for
direct one-shot range sampling without constructing a reusable `Uniform`
distribution. Alea keeps Zig-native `uniformChecked*` helpers and adds
camelCase `sampleSingle*` aliases for users coming from Rust.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/uniform.rs` documents
  `sample_single` and `sample_single_inclusive`;
- those methods validate ranges and return errors for invalid bounds;
- S4-M226 already added reusable `Uniform.new` / `newInclusive` constructor
  aliases, leaving one-shot Rust-discoverable naming as the next small
  unblocked uniform gap.

## Alea API Added

`src/distributions.zig` now exposes:

- `sampleSingle`;
- `sampleSingleFrom`;
- `sampleSingleInclusive`;
- `sampleSingleInclusiveFrom`.

Semantics:

- `sampleSingle` mirrors `uniformChecked`;
- `sampleSingleFrom` mirrors `uniformCheckedFrom`;
- `sampleSingleInclusive` mirrors `uniformInclusiveChecked`;
- `sampleSingleInclusiveFrom` mirrors `uniformInclusiveCheckedFrom`;
- invalid range errors are unchanged;
- sampling stream behavior is unchanged.

## Adoption and Documentation

- `examples/range_sampling.zig` prints `sampleSingle die=...` and
  `sampleSingleInclusive die=...`.
- `tools/examplecheck.zig` verifies the range example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M230.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "Uniform"`
- `zig build run-range-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked Uniform one-shot naming/discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
