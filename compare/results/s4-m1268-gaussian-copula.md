# S4-M1268 — Gaussian copula

## Goal

Add a Gaussian copula on the unit hypercube `(0,1)^dimension`, the standard
dependence model for correlated uniforms:

```
z ~ N(0, R),   u_i = Φ(z_i),
```

where `R` is a symmetric positive-semidefinite correlation matrix with unit
diagonal. Copulas are absent from local Rust `rand` / `rand_distr` core and let
users couple arbitrary marginal distributions through a shared dependence
structure.

## Implementation

### Public API

`StaticGaussianCopula(T, dimension)` (comptime dimension ≥ 1):

- `init(correlation: [dimension][dimension]T) GaussianCopulaError!Self` /
  `new(correlation) Self`
- `correlationValue(self) [dimension][dimension]T` — symmetrized correlation
- `dimensionValue(self) usize`
- `sample(self, rng) [dimension]T`, `sampleFrom(self, source) [dimension]T`
- `fill(self, rng, dest) void`, `fillFrom(self, source, dest) void`

Free-function family:

- `gaussianCopula`, `gaussianCopulaFrom`, `gaussianCopulaChecked`,
  `gaussianCopulaCheckedFrom`
- `fillGaussianCopula`, `fillGaussianCopulaFrom`,
  `fillGaussianCopulaChecked`, `fillGaussianCopulaCheckedFrom`

`GaussianCopulaError` aliases the distribution `Error` set. The `multi`
namespace also re-exports `StaticGaussianCopula`.

### Validation and sampling

1. Reject non-finite entries, non-unit diagonals (tolerance `1e-6`), and
   correlations outside `[-1, 1]`.
2. Symmetrize the input as `(R + Rᵀ)/2`; the copula only depends on the
   symmetric part.
3. Delegate positive-semidefinite validation and the Cholesky/factor
   computation to `StaticMultivariateNormal(T, dimension)` with a zero mean.
   Rank-deficient matrices (for example perfect correlation) are supported by
   the existing covariance factor.
4. Draw `z ~ N(0, R)` and map each coordinate through `normCdf`.
5. Clamp the resulting uniforms to `(ε/2, 1−ε/2)` so they remain valid inputs
   to marginal inverse-CDF helpers even at extreme normal quantiles.

The sampler is allocation-free and deterministic for a given engine and
correlation matrix.

## Tests added (7 new, total 779)

1. `Gaussian copula constructor validates correlation matrices` — NaN,
   non-unit diagonal, out-of-range correlation, non-PSD correlation, and
   symmetrization of a non-symmetric input.
2. `Gaussian copula with identity correlation has uniform independent marginals`
   — 5,000 samples; each marginal has mean ≈ 0.5, variance ≈ 1/12, and the
   probit-transformed cross moment is ≈ 0.
3. `Gaussian copula with perfect correlation returns equal uniforms` — rank-1
   correlation matrix yields identical coordinates.
4. `Gaussian copula recovers the input correlation` — 5,000 samples with
   ρ = 0.8; empirical probit correlation matches within 0.03.
5. `Gaussian copula free functions and fill work` — fill, checked, and
   invalid-matrix error paths.
6. `Gaussian copula direct-source sampling matches facade` — identical
   facade/direct streams for the same seed.
7. `Gaussian copula f32 sampling works`.

## Validation

- `zig build test` passes: 779/779 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "Gaussian copula"` passes 7/7.
- `docs/api-reference.md` updated for all 21 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1268 row added.

## Deviations and notes

- Only the comptime-dimension static variant is provided; an
  allocator-backed dynamic variant can follow the `MultivariateNormal(T)`
  pattern in a later milestone if runtime dimensions are needed.
- The `normCdf` mapping uses the existing Abramowitz–Stegun erf approximation
  (~1e-7 f64 accuracy), which is the same helper used by the distribution
  diagnostics. The open-interval clamp is an explicit boundary policy rather
  than an exact `Φ` evaluation at extreme quantiles.
- The Student-t copula is not included because it requires a Student-t CDF
  (regularized incomplete beta) that the library does not yet expose; it is a
  natural follow-up.

## Next bar

Student-t copula with an incomplete-beta CDF, dynamic-dimension Gaussian
copula, Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula or
Bingham sampling, longer statistical validation runs, or newly discovered core
gaps against local Rust `rand` / `rand_distr` evidence.
