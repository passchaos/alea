# S4-M1638 Vector Binomial pmf-Binned Long Gate

Date: 2026-11-15

## New Gate

Added `checkVectorBinomialBins(rng, vectors)` to the long-run check for the
S4-M1636 vectorized dyadic kernel. It samples `vectorBinomial(40, 0.25)`
vectors and bins the outcomes into 0-4, 5-9, ..., 35-39, 40 using exact
`Binomial(40, 0.25)` pmf probabilities (`lgamma` form), with the
`dof + 6·√(2·dof) = 7 + 6·√14 = 29.45` bound.

The continuous CDF-binning form is not equiprobable for discrete laws: the
first attempt (binning by `binomialCdf`) produced a 2.79M statistic at 1e7
samples because the CDF steps map whole outcome masses into fixed bins, so
the gate uses pmf bin probabilities instead.

## Results

- `alea-distcheck --long 10000000` passes (`distlongcheck ok (10000000
  samples)`).
- `alea-distcheck --long 1000000000` prints `distlongcheck ok (1000000000
  samples)` with the vector binomial pmf gate and the existing scalar/vector
  binned gates passing; the non-vector values reproduce S4-M1608/S4-M1615
  (`binomial(4)=0.237505`, `gamma(3)=0.450579`, normal tail `0.002698`,
  student-t tail `0.030104`, Gaussian copula `0.001875`).

## Validation

- `zig build test distcheck --summary all`: 971/971 (native 950/950); the
  default mode compiles the `checkLongRun` path containing the new gate.

## Changed Files

- `tools/distcheck.zig`: `checkVectorBinomialBins` and its call.
- Roadmap/audit evidence only; no library code, stream, or benchmark changed.
