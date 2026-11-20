# S4-M1869 1e9 Long-Run Refresh

Date: 2026-11-21

`alea-distcheck --long 1000000000` (the ReleaseFast binary built from the
S4-M1856 tree, run in the background for about 7.8 hours of CPU) prints
`distlongcheck ok (1000000000 samples)`. The run draws 1e9 samples in each
of the 28 long-run blocks and reproduces the S4-M1813 gate values exactly,
which confirms the sampling surface is unchanged by the CDF, geometry,
charset, and model work landed since then.

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
  `student-t(0)=0.499983`, `fisher-f(1)=0.534886`,
  `exponential(0.5)=0.632124`, `log-normal(1)=0.500017`,
  `log-logistic(1.5)=0.499978`, `nakagami(2)=0.745235`,
  `ex-gaussian(2)=0.460424`, `inverse-gaussian(1)=0.627680`,
  `skew-normal(0)=0.250011`, `pert(0.5)=0.500010`, `rice(1)=0.396501`,
  `hoyt(1)=0.662988`;
- tails: `normal=0.002698`, `exponential=0.049782`,
  `student-t=0.030104` (expected `0.030099`);
- copula 1% joint lower-tail rates: `gaussian=0.001875`,
  `student-t=0.003913`.

Coverage notes: the binary predates S4-M1858 (the Owen geometry cos
polynomial) and S4-M1860 (the vector von Mises cos polynomial). The
S4-M1858 change produced bit-identical public CDF values on a
393,060-point grid, and the long-run gates cover `VectorVonMisesFisher`,
`VectorWatson`, and `VectorBingham` but not the circular `VectorVonMises`
whose low bits S4-M1860 changed (that stream has its own 400M-lane audit
and the S4-M1862 long gate). The S4-M1863..M1868 reusable models add no
stream changes. The evidence therefore applies to the current tree.

## Validation

- `alea-distcheck --long 1000000000`: `distlongcheck ok (1000000000
  samples)`.

## Next Bar

The 4e9-sample or 24-hour soak and a fresh 128GiB PractRand pass (once
PractRand is installed) are the next statistical rungs; the
large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
