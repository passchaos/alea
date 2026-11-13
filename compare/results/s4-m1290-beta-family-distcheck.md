# S4-M1290 — BetaPrime/BetaBinomial distcheck coverage

## Goal

Extend `tools/distcheck.zig` with the Beta family additions so BetaPrime and
BetaBinomial are covered by the same deterministic statistical gate that runs
natively and through WASI.

## Implementation

New `checkBetaFamilies()` wired into `runChecks()`:

- BetaPrime(3, 5):
  - 20,000 samples,
  - mean in `[0.72, 0.78]` (exact 0.75),
  - variance in `[0.36, 0.52]` (exact 0.4375),
  - quantile round-trip `cdf(quantile(0.3)) ≈ 0.3`.
- BetaBinomial(10, 1, 1):
  - 20,000 samples,
  - uniform-case mean in `[4.9, 5.1]`,
  - variance in `[9.0, 11.0]`.
- BetaBinomial(20, 0.5, 0.5):
  - 20,000 samples,
  - overdispersed mean in `[9.8, 10.2]`,
  - variance in `[48.0, 57.0]` (exact 52.5),
  - PMF normalization over `0..20` within `1e-10`,
  - quantile coverage `cdf(quantile(0.7)) ≥ 0.7`.

## Validation

- `zig build distcheck` passes with the new checks.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`, so the Beta family gates also run on
  `wasm32-wasi-musl`.
- `zig build test` passes 836/836 tests with all documentation gates.
- `compare/results/core-rand-coverage.md` S4-M1290 row added.

## Notes

- The checks use only scalar samplers and stack buffers, so they remain
  allocator-free on WASI.
- The mean/variance windows are deliberately wider than the exact values to
  accommodate 20,000-sample noise while still catching regressions.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
