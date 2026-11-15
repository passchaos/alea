# S4-M1626 Vector Binned Chi-Square Gates

Date: 2026-11-15

## New Gate

Added `checkBinnedChiSquareVector(Model, VectorType, label, rng, vectors)` to
`tools/distcheck.zig`. It samples `Model.sample` vectors, bins every lane with
`Model.cdf` into the same 20 equiprobable bins as the scalar gate, and requires
the statistic to stay within six standard deviations of its `dof = 19` mean
(`19 + 6·√38 = 55.97`).

Applied to the six vector samplers whose streams changed in
S4-M1615/S4-M1618/S4-M1622/S4-M1624:

- `vectorCauchy` (0, 1) against `cauchyCdf`,
- `vectorPareto` (2, 3) against `paretoCdf`,
- `vectorGeneralizedExtremeValue` (1, 2, 0.3) against
  `generalizedExtremeValueCdf`,
- `vectorSkewNormal` (0, 1, 1) against `skewNormalCdf`,
- `vectorInverseGaussian` (1, 2) against `inverseGaussianCdf`,
- `vectorMaxwell` (2) against `maxwellCdf`.

Each gate draws `samples/16` vectors (`samples/4` lanes), matching the scalar
binned gates' statistical power and keeping the added runtime to about six
scalar-gate equivalents.

## Results

- `alea-distcheck --long 10000000` passes (`distlongcheck ok (10000000
  samples)`) with the six vector gates and the existing scalar/directional
  gates.
- `alea-distcheck --long 1000000000` prints `distlongcheck ok (1000000000
  samples)` with all gates passing; the non-vector values reproduce
  S4-M1608/S4-M1615 (`binomial(4)=0.237505`, `gamma(3)=0.450579`, normal tail
  `0.002698`, student-t tail `0.030104`, Gaussian copula `0.001875`).

## Validation

- `zig build test distcheck --summary all`: 971/971 (native 950/950); the
  default mode compiles the `checkLongRun` path containing the new vector
  gates.

## Changed Files

- `tools/distcheck.zig`: `checkBinnedChiSquareVector` and the six vector
  gates.
- Roadmap/audit evidence only; no library code, stream, or benchmark changed.
