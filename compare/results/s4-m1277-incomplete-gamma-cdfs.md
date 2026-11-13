# S4-M1277 — Incomplete gamma and Gamma/Chi-squared/Poisson CDFs

## Goal

Extend the distribution diagnostics surface with the regularized incomplete
gamma function and the CDFs/quantiles that depend on it:

- `gammaIncompleteP(a, x)` — regularized lower incomplete gamma.
- `gammaIncompleteQ(a, x)` — regularized upper incomplete gamma.
- `gammaCdf(x, shape, scale)` / `gammaQuantile(p, shape, scale)`.
- `chiSquaredCdf(x, dof)` / `chiSquaredQuantile(p, dof)`.
- `poissonCdf(k, λ)`.

Together with the S4-M1276 beta-based helpers, this gives the library CDF and
quantile coverage for the Beta, F, Student-t, Gamma, Chi-squared, and Poisson
families. Rust `rand_distr` does not provide these diagnostics.

## Implementation

### Regularized incomplete gamma

- `gammaSeriesP` uses the power series
  `P(a,x) = e^{-x} x^a / Γ(a) · Σ x^n / (a(a+1)…(a+n))` for `x < a + 1`.
- `gammaContinuedFractionQ` uses the Lentz continued fraction for `Q(a,x)` for
  `x ≥ a + 1`, with the same `64·ε` convergence and `floatMin·16` floor as the
  incomplete beta implementation.
- `gammaIncompleteP`/`Q` share the `x < a + 1` branch switch, return 0/1 at the
  endpoints, and return NaN for invalid shape or NaN `x`.

### Distribution CDFs and quantiles

- `gammaCdf(x, shape, scale) = P(shape, x/scale)`, matching alea's shape-scale
  Gamma parameterization.
- `gammaQuantile` doubles an upper bound from `scale·max(1, shape)` until the
  CDF reaches `p`, then bisects for 100 iterations; endpoints are 0/+∞.
- `chiSquaredCdf`/`chiSquaredQuantile` delegate to the Gamma helpers with
  `shape = dof/2`, `scale = 2`.
- `poissonCdf(k, λ) = Q(⌊k⌋ + 1, λ)` for `k ≥ 0`; `λ = 0` is the point mass at
  zero, and negative/invalid inputs follow the 0/NaN conventions.

## Tests added (4 new, total 820)

1. `gammaIncompleteP and gammaIncompleteQ match known values` — closed forms
   for `a = 1`, the `a = 0.5` erf identity, `P + Q = 1` across a 4×4 parameter
   grid, f32 support, and invalid/endpoint behavior.
2. `gammaCdf and gammaQuantile round-trip` — shape=1 scale=2 closed form,
   round-trip across p = 0.1/0.5/0.9 with shape=2.5 scale=1.5, and endpoint /
   invalid-parameter behavior.
3. `chiSquaredCdf and chiSquaredQuantile match known values` — chi²(1) and
   chi²(2) closed forms, 0.95 quantiles `3.8414588206941254` and
   `5.991464547107982`, round-trip for dof=4, and invalid dof.
4. `poissonCdf matches known values and point masses` — λ=2 CDF at k=1 and k=3,
   negative k, λ=0 point mass, k=+∞, invalid λ, and f32 support.

## Validation

- `zig build test` passes: 820/820 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "Cdf"` and
  `--test-filter "gammaIncomplete"` pass.
- `docs/api-reference.md` updated for all 7 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1277 row added.

## Deviations and notes

- The quantile helpers use deterministic bisection for robustness; they are
  diagnostics/ergonomics paths, not hot sampling paths.
- `poissonCdf` floors non-integer `k`, matching the usual integer-support CDF
  convention.
- Very large shape parameters can lose accuracy in `lgamma` differences; this
  is the same limitation as the existing Student-t and Beta helpers and is
  documented here rather than hidden.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
