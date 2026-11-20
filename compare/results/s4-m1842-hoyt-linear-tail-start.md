# S4-M1842 Linear Lower-Tail Start for the Hoyt Quantile

Date: 2026-11-20

## Gap

The Hoyt (Nakagami-q) quantile starts from the Rayleigh quantile
`sqrt(-omega·log(1-p))`, which is exact at `q = 1` but 10-11% off in the
lower tail for smaller `q` (the bench configuration `q = 0.5` averages 4.26
Newton iterations). Near zero the Hoyt density is linear in `x`, so the
CDF inverts in closed form there, exactly as for the Rice quantile.

## Change

For `p < 0.2` the start is `sqrt(2·p·q·omega/(1+q²))`, the exact inversion
of `F(x) ≈ a·x²·2q/(1+q²)`; above that the Rayleigh start is kept.

## Measurements

- Start error at `q = 0.5, omega = 1`: `p = 0.05` 11% → 1.6%.
- Direct `hoytQuantile(p, 0.5, 1)` sweep: 183.4 ns → 177.6 ns per call
  (about −3%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), nine alternating pairs:
  `hoyt quantile` medians 5.648M → 5.907M and 6.123M → 6.364M (about +4%);
  seven of the nine pairs favor the change.

## Accuracy

A round-trip audit over `q ∈ {0.1, 0.3, 0.5, 0.8, 1}`, `omega ∈ {0.5, 1,
5}`, and `p` from 1e-6 to `1 − 1e-6` gives a worst relative error of
6.96e-11; the start only changes the path, not the root.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The Hoyt quantile is now about 6.2M quantiles/s. Keep the no-known-gaps and
long-run evidence current, and revisit the large-hypergeometric codegen gap.
