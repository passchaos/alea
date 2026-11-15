# S4-M1608 Binned Chi-Square Long-Run Gates

Date: 2026-11-15

## Motivation

The long-run distribution gates check means and a few empirical CDF points.
A binned chi-square goodness-of-fit test compares the whole sampled
distribution against the CDF and can catch shape errors that a mean or a
single-point check would miss.

## Change

Added `checkBinnedChiSquare(Model, label, rng, samples)` to the long-run
check: it bins `Model.sample` by `Model.cdf` into 20 equiprobable bins and
requires the statistic to stay within six standard deviations of its
`dof = 19` mean (`19 + 6·√38 = 55.97`). The null chi-square distribution is
independent of the sample count, so the same bound is valid for the 1e7 and
1e9 long modes.

Applied to ten models (each with `samples / 4` draws):

- normal(0,1), exponential(1), gamma(3,1), beta(2,3), Student-t(5),
  log-normal(0,1), GEV(1,2,0.3), GPD(1,2,0.3), von Mises(0.5,5), and
  wrapped Cauchy(0.4,0.5).

The CDF binning also ties the sampler to the analytic CDF (including the new
GEV, von Mises, and wrapped Cauchy diagnostics) rather than to quantile
edges.

## Validation

- `alea-distcheck --long 10000000` prints
  `distlongcheck ok (10000000 samples)` in 16.8 s (about 1.6 s more than the
  previous long run) with all ten gates passing.
- `alea-distcheck --long 1000000000` prints
  `distlongcheck ok (1000000000 samples)` in about 27 minutes with all ten
  gates and the existing directional, GEV, von Mises, discrete, continuous,
  tail, and copula gates passing; the printed non-directional values
  reproduce S4-M1594/S4-M1589 (`binomial(4)=0.237505`,
  `gamma(3)=0.450579`, normal tail `0.002698`, student-t tail `0.030104`,
  Gaussian copula `0.001875`).
- Tooling-only change: no library code, sampling stream, public API, or
  benchmark changed.
