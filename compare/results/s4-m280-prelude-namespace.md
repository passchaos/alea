# S4-M280 Prelude Namespace Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes `rand::prelude::*` in
`~/Work/rand/src/prelude.rs`, re-exporting common RNG/distribution/sequence
items such as `Rng`, `RngExt`, `SeedableRng`, `StdRng`, `SmallRng`, and sequence
traits.

Alea does not copy Rust trait machinery, but a root `prelude` namespace helps
users compare local Rust examples and quickly find Alea's common modules and
aliases.

## Alea Change

Alea now provides:

```zig
prelude.Rng
prelude.Seed
prelude.distributions
prelude.seq
prelude.ascii
prelude.StdRng
prelude.SmallRng
prelude.SysRng
prelude.SysError
prelude.WeightError
```

These names are aliases over existing root declarations. The namespace does not
add Rust traits or hidden thread-local RNG behavior.

## Tests and Validation

Focused test coverage in `src/root.zig`:

- `root prelude namespace mirrors common aliases` verifies type/module equality
  for all prelude exports and matching stream shape for representative `StdRng`
  and `SmallRng` aliases.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  namespace.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M281.

Validation commands for this milestone:

```sh
zig fmt src/root.zig tools/roadmapcheck.zig
zig test src/root.zig --test-filter "prelude namespace"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust namespace discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
