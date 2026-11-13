# S4-M1279 — Sampler CDF/quantile methods

## Goal

Expose the CDF/quantile helpers added in S4-M1276 through S4-M1278 directly on
the reusable sampler structs, so users do not need to remember free-function
parameter orders:

- `Normal(T).cdf` / `Normal(T).quantile`.
- `Gamma(T).cdf` / `Gamma(T).quantile`.
- `Beta(T).cdf` / `Beta(T).quantile`.
- `ChiSquared(T).cdf` / `ChiSquared(T).quantile`.
- `StudentT(T).cdf` / `StudentT(T).quantile`.
- `FisherF(T).cdf` / `FisherF(T).quantile`.
- `Binomial.cdf` / `Binomial.quantile`.
- `Geometric.cdf` / `Geometric.quantile`.
- `NegativeBinomial.cdf` / `NegativeBinomial.quantile`.
- `Poisson.cdf` / `Poisson.quantile`.

Each method delegates to the corresponding free helper using the sampler's own
parameters, so the diagnostics stay consistent with the sampling configuration.

## Implementation

- Continuous samplers use their stored parameters directly:
  - Normal: `cdf(x) = Φ((x−mean)/stddev)`, `quantile(p) = mean + stddev·probit(p)`.
    A zero stddev is handled as a point mass.
  - Gamma/Beta/ChiSquared/StudentT/FisherF: delegate to
    `gammaCdf`/`betaCdf`/`chiSquaredCdf`/`studentTCdf`/`fisherFCdf` and the
    matching quantiles with the sampler's shape/scale/dof parameters.
- Discrete samplers use their integer parameters and probabilities:
  - Binomial: `binomialCdf(k, trials, p)`.
  - Geometric: `geometricCdf(k, p)` with one-based trial semantics.
  - NegativeBinomial: `negativeBinomialCdf(k, successes, p)`.
  - Poisson: `poissonCdf(k, lambdaValue())`, which preserves the zero-lambda
    point mass.
- Integer-to-float conversions use explicit `@as(f64, @floatFromInt(...))` so
  the generic free helpers receive a concrete type.

## Tests added (1 new, total 825)

`sampler cdf and quantile methods delegate to the free helpers` — for each of
the ten samplers, compares the method output against the free helper at one CDF
point and one quantile, including:
- normal point-mass stddev=0 behavior,
- Gamma/Beta/ChiSquared/StudentT/FisherF parameter delegation,
- Binomial/Geometric/NegativeBinomial/Poisson parameter delegation,
- typed floating arguments to avoid comptime-float specialization.

## Validation

- `zig build test` passes: 825/825 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- `docs/api-reference.md` updated for all 20 new public methods.
- `compare/results/core-rand-coverage.md` S4-M1279 row added.

## Deviations and notes

- The discrete methods take `f64` `k`/`q` arguments, matching the non-generic
  discrete sampler types; the continuous methods take the sampler's own `T`.
- Normal `cdf`/`quantile` handle `stddev = 0` explicitly instead of dividing by
  zero; the CDF returns a step function and the quantile returns the mean.
- No new special-function logic was added; this milestone is API ergonomics
  over the existing verified helpers.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
