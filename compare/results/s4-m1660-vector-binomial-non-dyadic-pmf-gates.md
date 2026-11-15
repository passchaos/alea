# S4-M1660 Vector Binomial Non-Dyadic pmf Gates

Date: 2026-11-16

## New Gates

Added `checkVectorBinomialPmfBins(rng, trials, p, width, bins, vectors)`, a
generic discrete pmf-binned gate for the vector binomial kernels with
arbitrary `p`, and applied it to the S4-M1650/S4-M1652 inverse-CDF region:

- `vectorBinomial(40, 0.4)` with 5-wide buckets (0-4, ..., 35-39, 40);
- `vectorBinomial(100, 0.4)` with 13-wide buckets (0-12, ..., 91-100).

Both use exact `Binomial(trials, p)` pmf probabilities and the
`dof + 6·√(2·dof) = 7 + 6·√14 = 29.45` bound.

## Results

- `alea-distcheck --long 10000000` passes (`distlongcheck ok (10000000
  samples)`).
- `alea-distcheck --long 1000000000` prints `distlongcheck ok (1000000000
  samples)` with the two new gates and the existing scalar/vector binned
  gates passing; the discrete CDF values match S4-M1658
  (`binomial(4)=0.237513`, `negative-binomial(3)=0.656249`,
  `geometric(2)=0.639988`) and the continuous/tail/copula values reproduce
  S4-M1608/S4-M1615.

## Validation

- `zig build test distcheck --summary all`: 971/971 (native 950/950); the
  default mode compiles the `checkLongRun` path containing the new gates.

## Changed Files

- `tools/distcheck.zig`: `checkVectorBinomialPmfBins` and its two calls.
- Roadmap/audit evidence only; no library code, stream, or benchmark changed.
