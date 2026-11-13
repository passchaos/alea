# S4-M1284 — Distcheck coverage for advanced multivariate and diagnostics APIs

## Goal

Extend `tools/distcheck.zig` beyond the scalar/vector distribution grid so the
new directional, copula, matrix-variate, and CDF/quantile APIs are covered by
the same deterministic statistical gate that runs natively and through WASI.

## Implementation

New `checkAdvancedMultivariate()` wired into `runChecks()`:

- Bingham 3D with `A = diag(0, −10, −10)`:
  - 20,000 samples,
  - unit-norm support gate,
  - dominant-axis concentration `E[x₀²] ∈ [0.86, 0.92]` (exact value ≈ 0.8927).
- Static Gaussian copula 2D with ρ = 0.7:
  - 10,000 samples,
  - open-interval uniform bounds,
  - empirical probit correlation `∈ [0.65, 0.75]`.
- Static Student-t copula 2D with ρ = 0.8, ν = 3:
  - 10,000 samples,
  - joint lower-tail rate `∈ [0.03, 0.15]` (independence baseline 0.01).
- Static matrix normal 2×2 with row covariance 0.6 and column covariance 0.4:
  - 20,000 samples,
  - empirical row/column cross moments in `[0.55, 0.65]` / `[0.35, 0.45]`.
- Static matrix-t 2×2 with identity covariances and ν = 5:
  - 20,000 samples,
  - second moment in `[1.5, 1.85]` (exact ν/(ν−2) = 5/3).
- Continuous CDF/quantile round-trips:
  - Beta, Gamma, Chi-squared, Student-t, and Fisher F at p = 0.3.
- Discrete CDF/quantile coverage:
  - Poisson (λ=5), Binomial (n=20, p=0.3), Geometric (p=0.4), and
    NegativeBinomial (s=3, p=0.5) at q = 0.7.
- Multivariate marginals:
  - `Dirichlet(T).marginalCdf` against `betaCdf(x, 2, 8)`,
  - `Multinomial.marginalCdf` against `binomialCdf(5, 20, 0.25)`.

The numeric arguments are explicitly typed as `f64` to avoid `comptime_float`
specialization in the generic helpers.

## Validation

- `zig build distcheck` passes with the new checks.
- `zig build wasi-report` passes end-to-end through Node WASI and ends with
  `profilelongcheck ok`, so the same advanced checks also run on
  `wasm32-wasi-musl`.
- `zig build test` passes 826/826 tests with all documentation gates.
- `compare/results/core-rand-coverage.md` S4-M1284 row added.

## Notes

- The Bingham threshold uses K=10 because K=5 gives an exact `E[x₀²] ≈ 0.7643`,
  which is too close to a broad lower bound to be a useful gate; K=10 gives
  `≈ 0.8927` with a tighter `[0.86, 0.92]` window.
- The new checks use the static matrix normal/matrix-t variants so distcheck
  stays allocator-free on WASI.
- No library code changed; this milestone strengthens statistical validation
  coverage for the recently added APIs.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
