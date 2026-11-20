# S4-M1852 Reciprocal Table in the Half-Shape erf Taylor

Date: 2026-11-20

## Gap

`gammaHalfErfTaylor` walks the erf Taylor series with a division in every
term (`term *= -x(2n-1)/(n(2n+1))`). At the gamma quantile's arguments
(`x ∈ [2.5, 8]`) the series needs about 27-35 terms for the 1e-17 stopping
test, so the CDF evaluation carried 27-35 divisions — roughly 40 ns of each
of the 3.08 quantile iterations. Zig 0.16 has no `std.math.erf`, so the
Taylor is the accurate path and cannot be replaced.

## Change

The per-term denominator `1/(n(2n+1))` is precomputed as a 41-entry comptime
table, so each term is a multiply chain (`term *= -x(2n-1)·inv[n]`) with no
division. The table values are exact comptime divisions, and the product
rounds the same way the direct quotient did.

## Measurements

- Direct `gammaQuantile(p, 2.5, 2)` sweep: 133.9 ns → 126.3 ns per call
  (about −6%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `gamma quantile` 5.983, 5.983, 5.982, 5.303 M/s before and 7.134, 7.273,
  7.337, 6.673 M/s after (median 5.983M to 7.204M, about +20%);
  `chi-squared quantile` 3.476, 3.996, 4.097, 3.465 M/s before and 4.945,
  4.340, 4.978, 4.617 M/s after (median 3.736M to 4.781M, about +28%). All
  eight pairs favor the change.

## Accuracy

The round-trip audit over `shape ∈ {0.05 … 9999}` and `p` from 1e-12 to
`1 − 1e-9` gives 1.980728948913768e-11 worst — bit-identical to the
pre-change value; the permanent half-integer series-comparison test still
passes at 1e-12.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The gamma quantile is now about 7.2M quantiles/s and the chi-squared
quantile about 4.8M/s. Keep the no-known-gaps and long-run evidence
current; the large-hypergeometric codegen gap (0.86-0.87x) remains the only
sub-parity comparable workload.
