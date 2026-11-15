# S4-M1644 Vector Geometric pmf-Binned Long Gate

Date: 2026-11-15

## New Gate

Added `checkVectorGeometricBins(rng, vectors)` to the long-run check for the
S4-M1642 vectorized dyadic geometric kernel. It samples
`vectorGeometric(0.25)` vectors and bins the trials into 1..7 and 8+ with
exact `Geometric(0.25)` probabilities (`p(1-p)^{k-1}`, last bin
`(1-p)^7`), with the `7 + 6·√14 = 29.45` bound.

## Results

- `alea-distcheck --long 10000000` passes (`distlongcheck ok (10000000
  samples)`).
- `alea-distcheck --long 1000000000` prints `distlongcheck ok (1000000000
  samples)` with the geometric pmf gate, the vector binomial pmf gate, and
  the existing scalar/vector binned gates passing; the non-vector values
  reproduce S4-M1608/S4-M1615 (`binomial(4)=0.237505`, `gamma(3)=0.450579`,
  normal tail `0.002698`, student-t tail `0.030104`, Gaussian copula
  `0.001875`).

## Validation

- `zig build test distcheck --summary all`: 971/971 (native 950/950); the
  default mode compiles the `checkLongRun` path containing the new gate.

## Changed Files

- `tools/distcheck.zig`: `checkVectorGeometricBins` and its call.
- Roadmap/audit evidence only; no library code, stream, or benchmark changed.
