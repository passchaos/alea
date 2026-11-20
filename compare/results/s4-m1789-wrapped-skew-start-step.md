# S4-M1789 One Skew-Normal Step for the Wrapped Quantile Start

Date: 2026-11-20

## Gap

Since S4-M1786 the wrapped skew-normal quantile starts from the wrapped
normal quantile, which is cheap but needs 5.21 image-sum Halley iterations.
A full skew-normal quantile solve (the old start) reduced that to 3.27
iterations but cost about 1 µs, so it was not worth it. The row sat at
0.44-0.48M quantiles/s.

## Change

After the wrapped-normal start, the quantile now takes one Newton step on the
standardized skew-normal CDF (`z -= (F_s(z) - p) / f_s(z)`) and wraps the
result back into `(-π, π]`. One step costs about 130 ns (one `skewNormalCdfZ`
plus one `skewNormalPdfZ`) and moves the start close to the skew-normal
quantile, cutting the image-sum iterations without paying for a converged
skew-normal solve. Non-finite or non-positive density falls back to the
wrapped-normal start.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new over two
batches:

| Batch | Before (M/s) | After (M/s) |
| --- | --- | --- |
| first | 0.438, 0.440, 0.443, 0.477 | 0.474, 0.474, 0.486, 0.498 |
| second | 0.448, 0.452, 0.465, 0.473, 0.476 | 0.499, 0.505, 0.510, 0.526, 0.527 |

The second batch separates cleanly: every new run is above every old run,
median 0.465 -> 0.510 (about +10%). The checksum is unchanged at the printed
resolution.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current and continue the Alea-only slow
rows (wrapped skew-normal CDF and the large-`alpha` small-`h·a` image).
