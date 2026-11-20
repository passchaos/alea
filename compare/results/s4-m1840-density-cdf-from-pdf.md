# S4-M1840 Derive the Quantile Density CDF from Its Own Density

Date: 2026-11-20

## Gap

Both skew-normal quantiles evaluate the Halley density terms with
`normCdf(alpha·z)`, which runs the Abramowitz-Stegun erf rational and needs
its own exponential — even though the block has already computed
`phi(alpha·z)` for the same argument. The density only steers the step
size; the root is set by the CDF, so the density's own accuracy target is
loose. In the wrapped quantile this single term was the largest remaining
per-iteration cost after the deep-tail skip.

## Change

A new `normCdfFromPdf(x, phi_x)` evaluates `Φ(x)` from the already-computed
`phi(x)` with the Abramowitz-Stegun 26.2.17 rational approximation
(|error| < 7.5e-8, no exponential). The wrapped quantile's density block
and `skewNormalPdfPairZ` (used by the skew-normal quantile and the wrapped
quantile's pre-step) now use it. The CDF paths are untouched.

## Measurements

- Direct `wrappedSkewNormalQuantile(p, 0.4, 1, 2)` sweep: 596.6 ns → 455.2
  ns per call (about −24%).
- Direct `skewNormalQuantile(p, 0, 1, 1)` sweep: 221.8 ns → 203.3 ns
  (about −8%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `wrapped skew-normal quantile` 1.103, 1.100, 1.101, 1.105 M/s before and
  2.063, 2.130, 1.993, 2.111 M/s after (median about +89%);
  `skew-normal quantile` 2.928, 3.119, 3.141, 3.143 M/s before and 4.946,
  4.895, 4.872, 4.752 M/s after (median about +56%).

## Accuracy

The S4-M1824 contract grid is unchanged at 5.49796e-11 worst round-trip
error, and the skew-normal audit is unchanged at 5.6717e-6 relative worst
in the deep tail — the density approximation only changes the intermediate
Halley steps, not the converged root.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 2M quantiles/s and the
skew-normal quantile about 4.9M/s. Keep the no-known-gaps and long-run
evidence current, and revisit the large-hypergeometric codegen gap.
