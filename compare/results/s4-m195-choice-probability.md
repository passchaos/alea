# S4-M195 Choice Optional Probability Lookup

Result: passed.

Purpose: add `Choice.probability()` as an optional single-probability lookup for
reusable unweighted choices. This mirrors the null-on-missing diagnostics style
added to static weighted samplers while preserving Alea's existing checked
`probabilityAt` and bulk probability export APIs.

## Local Reference

Local Rust `rand` exposes `distr::slice::Choose::num_choices()` for reusable
slice choices, while probability diagnostics are not a direct Rust API. Alea
already exceeded that with `Choice.probabilityAt` / `probabilitiesInto`; S4-M195
adds the more ergonomic optional lookup to match the S4-M193 weighted-sampler
shape.

## Alea API Added

`src/seq.zig` now exposes:

- `Choice.probability`.

Semantics:

- returns `?f64`;
- mirrors `probabilityAt(index)` for valid indexes;
- returns `null` out of bounds;
- preserves existing `probabilityAt`, `probabilities`, and
  `probabilitiesInto` behavior.

Focused tests verify in-range probabilities and out-of-range `null` behavior for
`Choice`.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `Choice.probability(0)=... missing=true`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the optional probability lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M196.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "choice sampler repeatedly samples"`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked reusable-choice diagnostics ergonomics gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
