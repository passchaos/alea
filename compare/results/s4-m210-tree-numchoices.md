# S4-M210 Dynamic Tree Count Diagnostics

Result: passed.

Purpose: add `WeightedTree.numChoices()` and `WeightedIntTree.numChoices()` as
count diagnostics for dynamic weighted samplers. Alea already exposed `len()` on
both tree types; S4-M210 adds naming consistent with reusable
`Choice.numChoices`, `WeightedChoice.numChoices`, `Charset.numChoices`, and
`AliasTable.numChoices`.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices, while cached `rand_distr` exposes dynamic weighted-tree APIs for
weighted index sampling. `WeightedTree` and `WeightedIntTree` are Alea's
Zig-native dynamic weighted samplers, so `numChoices()` is an
adoption/discoverability alias rather than a Rust trait port.

Relevant local references:

- `/home/passchaos/Work/rand/src/distr/slice.rs`
- cached local `rand_distr` weighted tree evidence under `~/.cargo/registry/src`

## Alea API Added

`src/distributions.zig` now exposes:

- `WeightedTree.numChoices`;
- `WeightedIntTree.numChoices`.

Semantics:

- returns `usize`;
- mirrors `len()`;
- tracks dynamic `push` / `pop` changes;
- does not allocate;
- does not consume randomness;
- preserves existing checked/optional weight and probability diagnostics,
  iterators, bulk exports, updates, and sampling behavior.

Focused tests verify that both tree families report the initial count, update the
count after push/pop, and report zero/one/zero across empty-tree push/pop
workflows.

## Adoption and Documentation

- `examples/weighted_sampling.zig` prints `dynamic tree numChoices: ...` and
  `integer tree numChoices: ...`.
- `tools/examplecheck.zig` verifies those example source tokens.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the count diagnostics.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M211.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "weighted tree supports dynamic updates"`
- `zig test src/root.zig --test-filter "weighted int tree supports dynamic updates"`
- `zig build run-weighted-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked dynamic weighted-sampler diagnostics gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
