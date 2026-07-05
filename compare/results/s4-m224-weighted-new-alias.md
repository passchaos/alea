# S4-M224 Weighted new Aliases

Result: passed.

Purpose: add Rust-discoverable construction aliases to static/reusable weighted
samplers. Local Rust `WeightedIndex::new` constructs a reusable weighted-index
distribution, and `rand::distr::slice::Choose::new` uses the same constructor
name for unweighted reusable choices. Alea keeps Zig-native `init` methods and
adds `new` aliases for discoverability.

## Local Rust Reference

Audited local Rust evidence:

- `/home/passchaos/Work/rand/src/distr/weighted/weighted_index.rs` exposes
  `WeightedIndex::new(weights)`;
- `/home/passchaos/Work/rand/src/distr/slice.rs` exposes `Choose::new(slice)`;
- S4-M223 already added `Choice.new`; S4-M224 applies matching constructor
  naming to weighted reusable/static samplers.

## Alea API Added

`src/distributions.zig` now exposes:

- `AliasTable.new`.

`src/seq.zig` now exposes:

- `WeightedChoice.new`.

Semantics:

- `AliasTable.new(allocator, weights)` mirrors `AliasTable.init`;
- `WeightedChoice.new(allocator, items, weights)` mirrors `WeightedChoice.init`;
- empty, length-mismatch, invalid-weight, and allocation-failure behavior is
  unchanged.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `alias new numChoices: ...` and
  `WeightedChoice.new numChoices: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the aliases.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M225.

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

This milestone closes an unblocked weighted constructor naming/discoverability
gap only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
