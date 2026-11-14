# S4-M1455 Billion-Sample Distribution Refresh

Date: 2026-11-14

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` with the current distribution code
(cached binomial, one-setup HIN fill, and the shared negative-binomial fill
rate). The gate values:

- discrete CDF: `binomial(4)` unchanged from S4-M1434 (`0.237505`),
  `poisson(5)=0.615949`, `hypergeometric(2)=0.372840`,
  `negative-binomial(3)=0.656260`, `geometric(2)=0.639990`,
  `zipf(2)=0.589003`, `zeta(1)=0.745437`, `bernoulli(0)=0.699995`.
- cached binomial CDF: `inversion(12)=0.575975`, `hin(100)=0.525687`.
- continuous CDF: `beta(0.3)=0.579825`, `gamma(3)=0.450579`,
  `student-t(0)=0.499983`, `fisher-f(1)=0.534886`,
  `exponential(0.5)=0.632124`, `log-normal(1)=0.500017`,
  `log-logistic(1.5)=0.499978`, `nakagami(2)=0.745235`,
  `ex-gaussian(2)=0.460424`, `inverse-gaussian(1)=0.627680`,
  `skew-normal(0)=0.250011`, `pert(0.5)=0.500010`, `rice(1)=0.396501`,
  `hoyt(1)=0.662988`.
- tails: `normal=0.002698`, `exponential=0.049782`,
  `student-t=0.030104` (expected `0.030099`).
- copula 1% joint lower-tail: `gaussian=0.001875`, `student-t=0.003913`.

The unchanged gates reproduce the S4-M1434 values, and the new cached-binomial
gates land within 0.0003 of the exact CDFs after 1e9 draws.
