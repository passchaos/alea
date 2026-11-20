# S4-M1870 Current-Tree 1e9 Long Run (ReleaseFast)

Date: 2026-11-21

`alea-distcheck --long 1000000000` built with
`zig build -Doptimize=ReleaseFast distcheck` from the S4-M1869 tree
(`dee10e16`) prints `distlongcheck ok (1000000000 samples)` after about
one hour of CPU. Unlike S4-M1859/S4-M1869, this binary is a ReleaseFast
build (the earlier long runs used Debug binaries, which cost about 9x
more: a 4M long check is 131 s of CPU in Debug and 14.3 s in
ReleaseFast).

This is the strongest long-run evidence so far because it covers the
**current** tree: the S4-M1858 Owen geometry cos polynomial, the S4-M1860
vector von Mises cos polynomial (now covered at 1e9 by the S4-M1862 lane
gate), the S4-M1856 packed charset fill, and the S4-M1863..M1868 reusable
models (no stream changes).

Gate values (identical to S4-M1813/S4-M1869):

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

The run also exercised the S4-M1862 `VectorVonMises` lane gate at 1e9
samples (inside the vector binned block), so the versioned cos-polynomial
stream is now validated at the long-run volume as well as by the
400M-lane audit.

## Validation

- `alea-distcheck --long 1000000000` (ReleaseFast): `distlongcheck ok
  (1000000000 samples)`.

## Next Bar

With ReleaseFast a 4e9 soak costs about 3.3 hours and is the next rung;
a 24-hour wall-clock soak and a fresh 128GiB PractRand pass (once
PractRand is installed) follow. The large-hypergeometric codegen gap
remains the only sub-parity comparable workload.
