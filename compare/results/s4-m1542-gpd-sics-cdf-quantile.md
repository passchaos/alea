# S4-M1542 Generalized-Pareto and Scaled-Inverse-Chi-Squared CDF/Quantile

Date: 2026-11-15

## Feature Gap

Every parameterized continuous family in the diagnostics surface had free
CDF/quantile helpers except `GeneralizedPareto` and
`ScaledInverseChiSquared`, which only had moments, support, and sampling.
Both have closed forms, so this was a surface inconsistency rather than a
mathematical limitation.

## Change

Added peer-type helpers and reusable-sampler methods:

- `generalizedParetoCdf` / `generalizedParetoQuantile` and
  `GeneralizedPareto(T).cdf` / `.quantile`.
- `scaledInverseChiSquaredCdf` / `scaledInverseChiSquaredQuantile` and
  `ScaledInverseChiSquared(T).cdf` / `.quantile`.

Generalized Pareto uses the closed form
`F(x) = 1 − (1 + ξ(x−μ)/σ)^(−1/ξ)` with `expm1`/`log1p` tails, the exact
exponential case for `ξ = 0`, the bounded support `μ − σ/ξ` for `ξ < 0`, and
the `σ = 0` point mass at `μ`. Scaled inverse chi-squared delegates to the
inverse-gamma form as `Q(ν/2, ντ²/(2x))`, ordering the product as
`(ν/2)·(τ²/x)` so huge scales do not overflow.

## Gamma Upper-Tail Refinement

The SICS round-trip probe exposed a limitation in `gammaQuantile`: near
`p = 1` the linear bisection compares lower-CDF values whose resolution is
one ulp of 1 (`~1e-16`), so the inverted upper-tail probability had
`~1e-5` relative error. `gammaQuantile` now bisects directly on
`gammaIncompleteQ` in log space when `1 − p < 1e-7`, where the continued
fraction resolves the upper tail to relative precision. This also improves
chi-squared and other gamma-derived upper-tail quantiles.

SICS `p = 1e-12` round-trip before/after (the exact target is
`1 − (1 − p) = 9.9997787828e-13`):

| stage | `cdf(quantile(1e-12))` | relative error |
| --- | --- | --- |
| lower-CDF bisection | 1.0000333894e-12 | +3.5e-5 |
| Q-space bisection | 9.9997787828e-13 | ~1e-15 |

## Tests and Gates

- `GeneralizedPareto CDF and quantile match closed forms` checks the
  exponential, `ξ = 0.2`, and bounded `ξ = −0.25` closed forms, extreme
  round-trips across all three shape regimes, the `σ = 0` point mass, the
  struct methods, and f32.
- `ScaledInverseChiSquared CDF and quantile match InverseGamma` checks
  agreement with `inverseGammaCdf`, moderate and extreme round-trips (using
  the representable `1 − (1 − p)` target for tiny p), edges, and f32.
- `distcheck` adds generalized-Pareto and scaled-inverse-chi-squared
  quantile round-trips to the continuous diagnostics block.
- `zig build test --summary all` passes 947/947 (native `alea-tests`
  928/928); `zig build distcheck` and `zig build doccheck` (including
  `apicheck` for the eight new symbols) pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
