# S4-M1859 50M Long-Run Refresh

Date: 2026-11-20

`alea-distcheck --long 50000000` (ReleaseFast binary built from the
S4-M1856 tree; sampling code and CDF values are unchanged by S4-M1858)
prints `distlongcheck ok (50000000 samples)`. The run draws 50M samples in
each of the 28 long-run blocks and takes about 27 minutes of CPU on this
host, which makes it the right same-session bar; a 1e9 run needs roughly
7-8 hours and is running in the background as the next stricter bar.

Gate values:

- discrete CDF means: `binomial(4)=0.237599`, `poisson(5)=0.615902`,
  `hypergeometric(2)=0.372783`, `negative-binomial(3)=0.656334`,
  `geometric(2)=0.640012`, `zipf(2)=0.589042`, `zeta(1)=0.745527`,
  `bernoulli(0)=0.699962`;
- cached binomial: `inversion(12)=0.576076`, `hin(100)=0.526503`;
- `hypergeometric huge`: `below=0.252420` (cdf `0.252492`),
  `above=0.747472` (cdf `0.747508`); `huge rare`: `empirical=0.526524`
  (cdf `0.526562`);
- `negative-binomial mixture`: `empirical=0.500232` (cdf `0.500275`);
- `beta huge`: `lower=0.002347` (cdf `0.002339`), `upper=0.997657`
  (cdf `0.997661`);
- continuous CDF means: `beta(0.3)=0.579853`, `gamma(3)=0.450558`,
  `student-t(0)=0.500027`, `fisher-f(1)=0.534849`,
  `exponential(0.5)=0.632092`, `log-normal(1)=0.500038`,
  `log-logistic(1.5)=0.500012`, `nakagami(2)=0.745159`,
  `ex-gaussian(2)=0.460407`, `inverse-gaussian(1)=0.627654`,
  `skew-normal(0)=0.250147`, `pert(0.5)=0.500025`, `rice(1)=0.396415`,
  `hoyt(1)=0.663090`;
- tails: `normal=0.002713`, `exponential=0.049746`,
  `student-t=0.030114` (expected `0.030099`);
- copula 1% joint lower-tail rates: `gaussian=0.001877`,
  `student-t=0.003919`.

The values are consistent with the S4-M1813 1e9 run (for example
`log-normal(1)` 0.500017 there versus 0.500038 here, and the student-t tail
0.030104 versus 0.030114 against the 0.030099 expectation) and every gate
passes at 5x the S4-M1497 10M bar.

The run covers the S4-M1783..M1856 sampling surface, including the
half-integer gamma recurrence, the Owen rule changes, the vector discrete
kernels, and the packed charset fill. S4-M1858 changed only the Owen
geometry build and produced bit-identical CDF values on the checked grid,
so this evidence applies to the current tree.

## Validation

- `alea-distcheck --long 50000000`: `distlongcheck ok (50000000 samples)`.

## Next Bar

The 1e9 background run is the next stricter statistical bar; the
large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
