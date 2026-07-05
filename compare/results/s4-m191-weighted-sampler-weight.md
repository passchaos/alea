# S4-M191 Optional Weighted Sampler Weight Lookup

Result: passed.

Purpose: add optional single-weight lookup helpers to static weighted samplers.
Local Rust `WeightedIndex::weight(index)` returns `Option<X>` for in-range or
out-of-range indexes. Alea already exposed checked/error-returning `weightAt`
helpers and bulk `weights` reconstruction; S4-M191 adds optional `weight()`
helpers for Rust-discoverable single-weight introspection while preserving the
existing Zig diagnostic APIs.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  `WeightedIndex::weight(&self, index: usize) -> Option<X>`;
- the same file exposes `WeightedIndex::weights()` as an iterator that calls
  `weight(index)` until it returns `None`.

Alea's alias-table based samplers reconstruct weights from alias columns rather
than cumulative weights, so the return type is normalized to `?f64` for the
existing `AliasTable` and `WeightedChoice` diagnostics surface.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.weight`.

`src/seq.zig` now exposes:

- `WeightedChoice.weight`.

Semantics:

- returns `?f64`;
- mirrors `weightAt(index)` for valid indexes;
- returns `null` out of bounds;
- preserves existing `weightAt`, `weights`, `weightsInto`, `probabilityAt`, and
  probability export behavior.

Focused tests verify in-range reconstructed weights, zero weights, out-of-range
`null`, and updated-table weights for `AliasTable`, plus matching weighted-choice
item sampler diagnostics.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias weight(2)=... missing=true` and
  `WeightedChoice.weight(2)=... missing=true` rows.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe optional weight lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M192.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "alias table exposes totals"`
- `zig test src/root.zig --test-filter "weighted choice sampler maps alias indexes"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked weighted-sampler introspection ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
