# S4-M1311 — Directional distribution example

## Goal

Add a runnable, cataloged example for the directional family so users can see
the scalar vMF, Kent, Bingham, matrix Fisher, matrix Langevin, and SIMD vMF
APIs in one place, with moment diagnostics that show the samplers are behaving
as documented.

## Changes

### `examples/directional.zig`

- Scalar von Mises-Fisher on S² (`κ = 5`): 5,000 samples, mean `z` vs
  `meanResultantLength()`.
- Kent (`κ = 5, β = 1.5`): 5,000 samples, mean resultant and γ₂/γ₃
  variances vs `varianceAt`.
- Bingham `diag(0, −3, −3)`: 5,000 samples, `E[x0²]`.
- Exact SO(3) matrix Fisher with `F = 2I`: 5,000 rotations, mean trace.
- Gibbs matrix Langevin on V_{2,3} with a zero second column: 1,000 samples
  after burn-in/thinning, first-column mean `z` and second-column zero mean.
- SIMD vMF `f64x4`: 2,000 vector samples, per-lane unit-norm assertions and
  lane mean `z`.

### Wiring

- `build.zig` adds `run-directional` and includes it in the aggregate
  `examples` step.
- `tools/examplecheck.zig` catalogs the example and its source tokens.
- `tools/toolingcheck.zig`, `docs/examples.md`, and `docs/tooling.md` list the
  new step.

## Evidence

Command: `zig build run-directional`

Observed output (abridged):

```
von Mises-Fisher mean z: 0.802 (expected 0.800)
kent mean resultant: 0.777 (expected 0.775)
kent gamma2 variance: 0.237 (expected 0.240)
kent gamma3 variance: 0.112 (expected 0.111)
bingham E[x0^2]: 0.623
matrix Fisher mean trace: 2.158
matrix vMF first-column mean z: 0.791
matrix vMF second-column mean: -0.017 -0.009 0.022
vector vMF lane mean z: 0.799
```

## Validation

- `zig build run-directional` passes and prints the moments above.
- `zig build examples` passes with the new example in the aggregate.
- `zig build test --summary all` passes 867/867 tests, including
  `examplecheck`, `toolingcheck`, `readmecheck`, and `roadmapcheck`.
- `compare/results/core-rand-coverage.md` S4-M1311 row added.

## Next bar

SIMD Kent/Watson/Bingham sampling, further long-run goodness-of-fit checks, or
newly discovered core gaps against local Rust `rand` / `rand_distr` evidence.
