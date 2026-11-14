# S4-M1498 Long-Run Empirical Gates for the Extreme CDF Paths

Date: 2026-11-14

## Change

`checkLongRun` now validates two of the hardened CDF paths against their
samplers at 1e6 samples:

- `negativeBinomial(2^20, 0.5)` empirical CDF at `1,048,576` (the mean)
  versus `negativeBinomialCdf(1,048,576, 2^20, 0.5) = 0.500275`;
- `Beta(1e10, 1e10)` empirical CDF at `0.5 ± 1e-5` versus the large-shape
  normal-fallback `betaCdf` values (`0.002339` and `0.997661`). The beta
  sampler uses the gamma-ratio path at this shape, so the gate checks the
  sampler and the CDF fallback together.

## Measured Values

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` prints
`distlongcheck ok (1000000 samples)` with:

- `long negative-binomial mixture cdf: empirical=0.501128 (cdf 0.500275)`,
- `long beta huge cdf: lower=0.002355 (cdf 0.002339)
  upper=0.997720 (cdf 0.997661)`.

All three deltas are below `0.001`, inside the helper's ±0.002 band.

## Validation

- `zig build test --summary all` passes 927/927 (native `alea-tests` 908/908).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
