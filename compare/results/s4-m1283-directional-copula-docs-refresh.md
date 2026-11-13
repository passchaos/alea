# S4-M1283 — Directional, copula, and matrix-variate documentation refresh

## Goal

Bring the first-contact documentation in sync with the directional, copula,
matrix-variate, and diagnostics APIs added after the previous docs refresh:

- README feature overview.
- `docs/core-guide.md` distribution guidance.

The API reference was already updated per symbol; this milestone covers the
prose and discovery layer that users read before opening the API reference.

## Changes

### README

- Extended the distribution feature bullet with von Mises, wrapped Cauchy,
  von Mises-Fisher, Watson, Bingham, truncated normal, Gaussian/Student-t
  copulas, matrix normal, matrix-variate Student-t, and
  Wishart/Inverse-Wishart.
- Added the `multi.*` namespace names for the new copula and matrix-variate
  families.
- Added a distribution-diagnostics bullet covering `normCdf`/`probit`,
  beta/gamma/chi-squared/Student-t/Fisher-F CDFs and quantiles, discrete
  CDFs/quantiles, Dirichlet/Multinomial marginal CDFs, and sampler-level
  `cdf`/`quantile` methods.

### Core guide

- New `## Directional, Copula, and Matrix-Variate Distributions` section:
  - circular/spherical families (`VonMises`, `WrappedCauchy`,
    `VonMisesFisher`, `Watson`, `Bingham`),
  - static and allocator-backed Gaussian/Student-t copulas,
  - matrix normal, matrix-t, and Wishart/Inverse-Wishart families,
  - `multi.*` discovery aliases and the `run-copulas` / `run-matrix-normal`
    examples.
- New `## Distribution Diagnostics` section documenting the CDF/quantile
  helper families, Dirichlet/Multinomial marginals, sampler methods, and the
  bisection/endpoint/point-mass conventions.

## Validation

- `zig build test` passes: 826/826 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- `zig build run-copulas` and `zig build run-matrix-normal` remain the
  executable examples referenced by the new core-guide section.
- `compare/results/core-rand-coverage.md` S4-M1283 row added.

## Notes

- No library code or public symbols changed; this milestone is documentation
  and discovery work.
- The new sections intentionally point at the existing examples rather than
  duplicating their output, keeping the core guide stable as examples evolve.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
