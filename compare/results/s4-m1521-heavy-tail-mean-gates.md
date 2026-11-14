# S4-M1521 Heavy-Tail Sampler Mean Gates and Scalar Moment Audit

Date: 2026-11-15

## Audit

A standalone probe sampled 17 scalar distributions with non-default
parameters and compared empirical means/variances against their
`expectedValue()` / `varianceValue()` accessors at 200,000 and 2,000,000
samples:

- log-normal(0.5, 0.75), Weibull(2, 1.5), Frechet(1, 2, 3), Pareto(2, 3),
  log-logistic(2, 3), Kumaraswamy(2, 3), triangular(1, 2, 5),
  PERT(0, 1, 2, 4), skew-normal(1, 2, 3), ExGaussian(1, 2, 3),
  generalized-Pareto(1, 2, 0.3), inverse-gamma(4, 2), Nakagami(2, 1),
  Rice(1, 1), Hoyt(0.5, 1), noncentral-chi-squared(3, 4), and
  scaled-inverse-chi-squared(5, 2).

At 2M samples every empirical mean matched its accessor within 0.13% and
every light-tail variance matched within 0.3%. The 200k variance estimates
for Pareto(2, 3), generalized-Pareto(1, 2, 0.3), scaled-inverse-chi-squared
(5, 2), Frechet(1, 2, 3), and log-logistic(2, 3) deviated by up to 21%
because those parameter sets have infinite fourth moments, so the sample
variance converges slowly; at 2M they moved toward the reference
(Pareto −12.0% → −3.3%, generalized-Pareto −6.2% → +1.5%,
scaled-inverse-chi-squared −20.7% → −7.4%). No sampler transform bug was
found.

## Change

`tools/distcheck.zig` `checkContinuous` now gates the means of the
heavy-tail and inverse families that previously had support or CDF coverage
but no continuous mean gate:

| gate | parameters | expected mean | range | samples |
| --- | --- | --- | --- | --- |
| `pareto` | scale 2, shape 3 | 3 | [2.90, 3.10] | 100,000 |
| `generalized-pareto` | μ 1, σ 2, ξ 0.3 | 3.8571 | [3.75, 3.95] | 100,000 |
| `inverse-gamma` | shape 4, scale 2 | 0.6667 | [0.64, 0.69] | 50,000 |
| `scaled-inverse-chi-squared` | df 5, scale² 2 | 3.3333 | [3.20, 3.45] | 100,000 |
| `ex-gaussian` | μ 1, σ 2, τ 3 | 4 | [3.90, 4.10] | 50,000 |
| `triangular` | 1, 2, 5 | 2.6667 | [2.60, 2.73] | 25,000 |
| `nakagami` | m 2, Ω 1 | 0.9400 | [0.92, 0.96] | 50,000 |
| `rice` | ν 1, σ 1 | 1.5486 | [1.52, 1.58] | 50,000 |
| `hoyt` | q 0.5, Ω 1 | 0.8643 | [0.85, 0.88] | 50,000 |

Ranges are at least ~6 standard errors of the mean for the finite-variance
parameters and remain robust to the heavy-tail mean estimator.

## Validation

- `zig build distcheck --summary all` passes with the nine new gates.
- `zig build test --summary all` passes 938/938 (native `alea-tests`
  917/917); no library code changed.

The aggregate `validate-all` refresh is tracked as the following milestone.
