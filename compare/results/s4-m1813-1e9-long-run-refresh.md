# S4-M1813 1e9 Long-Run Refresh After the Quantile Optimization Wave

Date: 2026-11-20

`alea-distcheck --long 1000000000` (ReleaseFast binary, run directly) prints
`distlongcheck ok (1000000000 samples)` after the S4-M1783..M1812 wave.

Gate values:

- discrete CDF means: `binomial(4)=0.237514`, `poisson(5)=0.615957`,
  `hypergeometric(2)=0.372835`, `negative-binomial(3)=0.656237`,
  `geometric(2)=0.640005`, `zipf(2)=0.588979`, `zeta(1)=0.745432`,
  `bernoulli(0)=0.700006`;
- cached binomial: `inversion(12)=0.575974`, `hin(100)=0.526570`;
- `hypergeometric huge`: `below=0.252478` (cdf `0.252492`),
  `above=0.747515` (cdf `0.747508`); `huge rare`: `empirical=0.526539`
  (cdf `0.526562`);
- `negative-binomial mixture`: `empirical=0.500289` (cdf `0.500275`);
- `beta huge`: `lower=0.002338` (cdf `0.002339`), `upper=0.997660`
  (cdf `0.997661`);
- continuous CDF means: `beta(0.3)=0.579825`, `gamma(3)=0.450579`,
  `student-t(0)=0.499983`, `fisher-f(1)=0.534886`, `exponential(0.5)=0.632124`,
  `log-normal(1)=0.500017`, `log-logistic(1.5)=0.499978`,
  `nakagami(2)=0.745235`, `ex-gaussian(2)=0.460424`,
  `inverse-gaussian(1)=0.627680`, `skew-normal(0)=0.250011`,
  `pert(0.5)=0.500010`, `rice(1)=0.396501`, `hoyt(1)=0.662988`;
- tails: `normal=0.002698`, `exponential=0.049782`,
  `student-t=0.030104` (expected `0.030099`);
- copula 1% joint lower-tail rates: `gaussian=0.001875`,
  `student-t=0.003913`.

No library code changed in this milestone. The run covers the Halley quantile
wave, the Owen T tables and band/far-tail changes, the Marcum/von Mises
term-bound tightening, the direct-form ex-Gaussian/Rice densities, the
image-range bounds, the Taylor erfc, the Rice Wilson-Hilferty start, and the
tiny-quantile log refinements.

## Validation

- `alea-distcheck --long 1000000000`: `distlongcheck ok (1000000000 samples)`.

## Next Bar

Keep the no-known-gaps comparison and this long-run evidence current. Known
remaining limits (recorded in S4-M1797/M1811/M1812): the `beta(0.1,0.1)`
upper tail is bounded by f64 representability near 1.0, and the
`hoyt(q=0.01)` series needs a small-q reformulation before that range can be
trusted.
