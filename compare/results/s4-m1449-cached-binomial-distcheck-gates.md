# S4-M1449 Cached Binomial Distcheck Gates

Date: 2026-11-14

## Gap

S4-M1444 and S4-M1447 added `CachedBinomial` with unit moment tests, but the
aggregate `distcheck` and the long-run sweep did not gate the new sampler. A
drift in the cached dispatch or in the inverse-CDF walk would only be caught
by the unit tests.

## Change

- `checkBinomial` now samples `CachedBinomial(1000, 0.012)` (inversion region)
  and `CachedBinomial(10000, 0.01)` (HIN region) with 10,000 draws each and
  gates the mean at `[11.8, 12.2]` and `[98.8, 101.2]`.
- `checkLongRun` adds a dedicated block: mean and variance gates for both
  regions plus empirical-CDF gates at 8/12/16 (inversion) and 90/100/110
  (HIN) against the exact `binomialCdf` references.
- The long-run output adds
  `long cached binomial cdf: inversion(12)=... hin(100)=...`.

## Validation

- `zig build distcheck` prints `distcheck ok`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `long cached binomial cdf: inversion(12)=0.575781 hin(100)=0.525774` and
  `distlongcheck ok (10000000 samples)`.
- `zig build test --summary all` passes 908/908 tests (native 889/889).
- `zig build roadmapcheck` passes.
