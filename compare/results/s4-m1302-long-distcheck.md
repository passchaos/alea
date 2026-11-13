# S4-M1302 — Long-run distribution validation mode

## Goal

Add an opt-in longer statistical validation run on top of `distcheck`, so the
core and recently added multivariate/directional families can be checked at
1,000,000 seeded samples instead of the default 20,000–40,000.

## Changes

### `tools/distcheck.zig`

- `main` now parses `--long [samples]` on native targets (default
  1,000,000 samples). WASI keeps the existing short-check behavior.
- `checkLongRun(samples)` adds seeded moment-recovery gates for:
  - standard normal (mean, variance),
  - standard exponential (mean, variance),
  - Poisson(4) (mean, variance),
  - Gamma(2.5, 1.5) (mean, variance),
  - 2D multivariate normal with `[1, 0.3; 0.3, 1]` covariance
    (means, variances, covariance),
  - 2D multivariate Student-t with `ν = 5` (means, actual covariance
    `ν/(ν−2)`),
  - 2D multivariate skew-normal (Azzalini mean, variance, covariance),
  - Kent `κ = 5, β = 1.5` (mean resultant, γ₂/γ₃ variances),
  - Bingham `diag(0, −3, −3)` against a direct numerical integral,
  - von Mises-Fisher `κ = 5` (mean resultant).
- Tolerances are roughly five standard errors at the requested sample count,
  so the gates catch distribution bugs without becoming seed-sensitive.

### `build.zig`

- The native `distcheck` executable now forwards `zig build ... -- ...` args,
  enabling `zig build distcheck -- --long 1000000` without a new build step or
  tooling catalog entry.

## Evidence

Command:
`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000`

Output: `distlongcheck ok (1000000 samples)`

The run also executes the normal parameter-grid checks and the distcheck
helper tests first.

## Validation

- `zig build distcheck` still passes in the default short mode.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes all
  long-run gates.
- `zig build test --summary all` passes 852/852 tests with all documentation
  gates.
- `zig fmt --check tools/distcheck.zig build.zig` passes.
- `compare/results/core-rand-coverage.md` S4-M1302 row added.

## Next bar

Matrix von Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, further
long-run tail/correlation checks, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
