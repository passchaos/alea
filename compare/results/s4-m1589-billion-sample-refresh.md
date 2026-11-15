# S4-M1589 Billion-Sample Refresh After S4-M1583..S4-M1587

Date: 2026-11-15

## Run

Rebuilt the ReleaseFast `alea-distcheck` from the current tree and ran it
directly so the host build-tree timeout does not apply:

```
./.zig-cache/o/24abcc464ee87bf18d83fc994d6e7b26/alea-distcheck --long 1000000000
```

The run takes about 22-24 minutes and prints
`distlongcheck ok (1000000000 samples)` on success. The shell redirect shares
one output file between buffered stdout and unbuffered stderr, so the
completion line lands at offset 0 while the later gate lines follow it; the
line and the gate values below are from the same run.

## Gate Values

Discrete CDF gates reproduce the S4-M1564 values:

- `binomial(4)=0.237505`, `poisson(5)=0.615949`,
  `hypergeometric(2)=0.372840`, `negative-binomial(3)=0.656260`,
  `geometric(2)=0.639990`, `zipf(2)=0.589003`, `zeta(1)=0.745437`,
  `bernoulli(0)=0.699995`
- cached binomial: `inversion(12)=0.575974`, `hin(100)=0.526570`

Huge-parameter and continuous gates:

- huge hypergeometric `below=0.252478 (cdf 0.252492)`,
  `above=0.747515 (cdf 0.747508)`, rare `0.526539 (cdf 0.526562)`
- negative-binomial mixture `0.500289 (cdf 0.500275)`
- beta huge `lower=0.002338 (cdf 0.002339)`,
  `upper=0.997660 (cdf 0.997661)`
- continuous: `beta(0.3)=0.579825`, `gamma(3)=0.450579`,
  `student-t(0)=0.499983`, `fisher-f(1)=0.534886`,
  `exponential(0.5)=0.632124`, `log-normal(1)=0.500017`,
  `log-logistic(1.5)=0.499978`, `nakagami(2)=0.745235`,
  `ex-gaussian(2)=0.460424`, `inverse-gaussian(1)=0.627680`,
  `skew-normal(0)=0.250011`, `pert(0.5)=0.500010`, `rice(1)=0.396501`,
  `hoyt(1)=0.662988`
- tails: `normal=0.002698`, `exponential=0.049782`,
  `student-t=0.030104` (expected `0.030099`)
- Gaussian/Student-t copula 1% joint lower-tail rates:
  `gaussian=0.001875`, `student-t=0.003913`

All values match the S4-M1564 billion-sample refresh, confirming that the
S4-M1583..S4-M1587 directional changes did not perturb the non-directional
samplers.

## Directional Long Gates

The same run also executes the silent long gates for the changed samplers at
1e9 samples: scalar Kent mean-resultant/variance, scalar vMF mean-resultant,
`VectorVonMisesFisher` lane mean, `VectorKent` lane mean-resultant, Bingham
mean `x0²`, scalar/vector Watson moments, matrix vMF Gibbs marginal means,
and the matrix Fisher O(3) determinant frequency. No gate reported a
failure, so the exact truncated-exponential marginal, the scalar-per-lane
vector vMF, and the vector Kent uniform-angle branch hold their moments at
the billion-sample scale.

## Validation

- Evidence-only milestone: no library code, stream, API, or benchmark
  changed.
- `compare/results/reproducibility-matrix.md` already records the
  S4-M1583..S4-M1587 streams; this run confirms them at 1e9 samples.
