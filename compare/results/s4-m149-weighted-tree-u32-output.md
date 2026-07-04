# S4-M149 Weighted Tree u32 Output

Result: passed.

Purpose: add compact `u32` index output to dynamic weighted trees. Earlier
milestones added `u32` index output for one-shot weighted indexes,
allocation-returning batches, reusable `WeightedChoice`, and weighted
no-replacement helpers. Dynamic `WeightedTree` / `WeightedIntTree` still only
returned `usize` indexes, requiring callers with `u32` populations to allocate
or cast after sampling.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/seq/index.rs` returns compact internal
  `IndexVec` variants for sampling indices where possible.
- `/home/passchaos/Work/rand/src/seq/slice.rs` maps weighted index samples back
  to items for weighted slice workflows.
- cached local `rand_distr 0.6.0` exposes `weighted::WeightedTreeIndex` as a
  dynamic weighted-index sampler returning `usize`.

Alea already exceeded this in several sequence APIs with explicit `u32`
variants. This milestone extends that compact-output ergonomics to dynamic
weighted trees while keeping Rust-compatible `usize` behavior as the default.

## Alea API Added

`src/distributions.zig` now exposes for both `WeightedTree(Weight)` and
`WeightedIntTree(Weight)`:

- `sampleU32`;
- `sampleU32Checked`;
- `sampleU32From`;
- `sampleU32CheckedFrom`;
- `fillU32`;
- `fillU32Checked`;
- `fillU32From`;
- `fillU32CheckedFrom`.

Checked `u32` helpers reject populations longer than `std.math.maxInt(u32)`.
They otherwise mirror the existing `usize` sample/fill helpers, including
single-positive fast paths and zero-length fill behavior.

Focused tests verify:

- `WeightedTree(f64)` and `WeightedIntTree(u32)` `sampleU32*` facade/direct
  parity;
- `fillU32*` output matches `fill*` output under the same seed after casting;
- single-positive trees return compact indexes without consuming the random
  stream;
- invalid all-zero trees report `InvalidWeight` for non-empty outputs while
  zero-length compact fills return before validating totals.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree sample u32 index` and
  `integer tree u32 sample indices`.
- `tools/examplecheck.zig` verifies those tokens and the `sampleU32/fillU32`
  summary token.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe compact dynamic-tree index output.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree u32 sampling helpers"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted dynamic-tree ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
