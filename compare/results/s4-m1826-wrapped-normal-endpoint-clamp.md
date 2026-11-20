# S4-M1826 Saturated Endpoint Terms in the Wrapped Normal Cache

Date: 2026-11-20

## Gap

`WrappedNormalCdfCache.ensureTerms` evaluated `normCdf(z_end)` for every
endpoint image, including images 9-15 sigma out. For the lower endpoint
`z_end` is far negative there, and `normCdfScalarF64` resolves negative
arguments beyond 6 sigma with the Mills-ratio asymptotic series, which
truncates only near `k ≈ x²/2` — about 48 terms at `x = 9.8`. One such term
per call was roughly a third of the wrapped normal quantile.

The cache backs both the public wrapped normal CDF and its quantile.

## Change

The endpoint term is now clamped to its limiting value once `z_end` leaves
the same 9-sigma band the evaluation loop already uses for its skip test:
`1` for `z_end >= 9`, `0` for `z_end <= -9`, otherwise `normCdf(z_end)`.
The true term beyond the band is below 6e-23, far under f64 resolution of
the surrounding sum.

## Accuracy

Against an unclamped reference image sum over `sigma ∈ {0.2, 0.5, 1, 2, 3,
6, 9}`, `mu ∈ {0.4, −1.7, 3}`, and 800 interior points on `[−π, π]`, the
worst deviation is 1.11e-16 (one ulp). The only larger difference anywhere
is the public API's existing `x >= π` endpoint clamp, which predates this
change.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped normal quantile` | 4.583, 4.662, 4.615 | 5.998, 6.017, 6.044 |

About +30% with identical checksums (`5876.009`). The public wrapped normal
CDF uses the same cache and benefits from the same clamp; it has no
dedicated bench row.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped normal quantile moved from about 4.6M to 6.0M quantiles/s. The
same saturated-endpoint pattern is now handled in the wrapped normal and
wrapped skew-normal caches; keep the no-known-gaps and long-run evidence
current.
