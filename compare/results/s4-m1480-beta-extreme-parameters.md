# S4-M1480 Beta-Family Extreme-Parameter Stability

Date: 2026-11-14

## Change

The beta-family normal fallback and moment helpers computed products such as
`a·b`, `a + b`, `d2²·(d1 + d2)`, and `β²` directly. For huge finite shapes
those products overflow f64, so `betaIncomplete` clamped a NaN to 1,
`betaQuantile` bisected to 0, and the moment helpers returned NaN.

`betaIncomplete` now evaluates the `a + b ≥ 1e7` normal/Edgeworth branch from
normalized probabilities `p = a/(a+b)`, `q = 1 − p`:

- variance `p·q/(a+b+1)` and skew `2·(q−p)·√(a+b+1)/((a+b+2)·√(p·q))`, both
  bounded by construction;
- an overflowing `a + b` (finite shapes summing past `f64` max) degenerates to
  a point mass at `p`, so the CDF is a step;
- a zero standard deviation returns the step value directly instead of
  dividing by zero.

The moment helpers use algebraically equivalent scaled forms:

- `Beta.expectedValue` / `varianceValue`: `p = a/(a+b)`, variance
  `p·q/(a+b+1)`; an overflowing sum uses `p = 1/(1+b/a)` and
  `p²·q/a = p·q/(a+b)`;
- `BetaBinomial.expectedValue` / `varianceValue`: `n·p` and
  `n·p·q·(1 + (n−1)/(a+b+1))`;
- `BetaPrime.varianceValue`: `m·(1 + m)/(β − 2)` with `m = α/(β − 1)`;
- `FisherF.varianceValue`: `2·m²·(1/(d2−4) + (d2−2)/(d1·(d2−4)))` with
  `m = d2/(d2 − 2)`;
- `InverseGamma.varianceValue`: `mean²/(α − 2)` with `mean = β/(α − 1)`;
- `InverseGaussian.varianceValue`: `(μ/λ)·μ²` instead of `μ²·μ/λ`;
- `Dirichlet.meanAt`/`meansInto`, `varianceAt`/`variancesInto`,
  `covarianceAt`/`covariancesInto`: when the alpha total overflows, rescale by
  the largest alpha and use the normalized weights `alpha_i/scale` divided by
  `Σ alpha/scale`.

No RNG stream changed: the CDF and moment helpers are deterministic functions,
and the `Beta` sampler's infinite-shape NaN/point-mass stream contract is
untouched.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `betaIncomplete(0.5, 1e300, 1e300)` | 1 (NaN clamp) | 0.5 | 0.5 |
| `betaIncomplete(0.4, 1e300, 1e300)` | 1 | 0 | 0 |
| `betaQuantile(0.5, 1e300, 1e300)` | 7.1e-15 | 0.5 | 0.5 |
| `fisherFCdf(1, 1e300, 1e300)` | 1 | 0.5 | 0.5 |
| `betaIncomplete(0.25, 1e308, 9e307)` | NaN | 0 | step at 1/1.9 = 0.526 |
| `Beta(1e300, 1e300).cdf(0.5)` | 1 | 0.5 | 0.5 |
| `Beta(1e300, 1e300).varianceValue()` | NaN | 1.25e-301 | 1.25e-301 |
| `BetaBinomial(10, 1e300, 1e300).varianceValue()` | NaN | 2.5 | 2.5 |
| `BetaPrime(1e300, 1e300).varianceValue()` | NaN | 2e-300 | 2e-300 |
| `FisherF(1e300, 1e300).varianceValue()` | NaN | 4e-300 | 4e-300 |
| `FisherF(1e-300, 1e300).varianceValue()` | NaN | 2e300 | 2e300 |
| `InverseGamma(1e300, 1e300).varianceValue()` | NaN | 1e-300 | 1e-300 |
| `InverseGaussian(1e150, 1e300).varianceValue()` | inf | 1e150 | 1e150 |
| `Dirichlet{1e308, 1e308}.meanAt(0)` | 0 | 0.5 | 0.5 |
| `Dirichlet{1e308, 1e308}.varianceAt(0)` | NaN | 1.25e-309 | 1.25e-309 |
| `Dirichlet{1e308, 1e308}.covarianceAt(0, 1)` | NaN | −1.25e-309 | −1.25e-309 |
| `negativeBinomialCdf(1e300, 1e300, 0.5)` | NaN | 0.5 | 0.5 |

The reference column is the algebraic limit: for equal huge shapes the beta
law concentrates at 1/2 with variance `1/(8·a)`, the F law at 1 with variance
`4/d2`, and the Dirichlet weights at `1/n` with variance
`p·(1−p)/(Σα+1)`.

## Validation

- `zig build test --summary all` passes 919/919 (native `alea-tests` 900/900).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
