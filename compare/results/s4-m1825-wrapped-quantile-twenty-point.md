# S4-M1825 Twenty-Point Owen Rule in the Wrapped Skew-Normal Quantile Cache

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile cache still built and evaluated the
24-point Owen T Gauss-Legendre geometry for every shape. S4-M1817 had
already shown that a 20-point rule is accurate to about 6e-13 for
`|alpha| <= 2` and adopted it for the plain skew-normal quantile; the
wrapped cache never got the same treatment, so each image evaluation spent
24 exponentials on the quadrature instead of 20.

## Change

`WrappedSkewNormalCdfCache` now builds the 20-point table when
`0 < |alpha| <= 2` and routes the point and endpoint terms through
`skewNormalCdfZWithGlTable20` / the new
`skewNormalUpperTailZWithGlTable20` helper. Wider shapes keep the 24-point
rule, and `|alpha| > 6` keeps the generic path. The gate only applies to the
quantile cache; the public CDF is unchanged.

## Accuracy

The end-to-end contract audit (`CDF(quantile(p))` over `sigma ∈ {0.2, 0.5,
1, 2, 3, 6, 9}`, `alpha ∈ {−10, −6, −2, −0.5, 0, 0.5, 2, 6, 10}`, `p ∈
{1e-4, 0.01, 0.1, 0.5, 0.9, 0.99, 1−1e-4}`) gives a worst error of
5.49796e-11 with the 20-point rule versus 5.49799e-11 with the 24-point
rule: the saturated-endpoint clamp from S4-M1824 dominates, and the 20-point
rule adds nothing measurable. The 1e-9 contract is unchanged.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating 24-point/20-point.
The first batch ran while the host was busy; the second batch ran on a
quieter window:

| Window | 24-point (M/s) | 20-point (M/s) |
| --- | --- | --- |
| busy | 0.583, 0.636, 0.626 | 0.688, 0.636, 0.604 |
| quiet | 0.860, 0.814, 0.845, 0.791, 0.798 | 0.884, 0.878, 0.884, 0.805, 0.837 |

In the quiet window every paired run favored the 20-point rule; medians are
0.814M versus 0.878M quantiles/s (about +8%). Checksums are identical
(`4282.426`) in every run.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 0.88M quantiles/s. The
remaining cost is the 4.53-iteration Halley solve itself (about 156 ns per
image evaluation); the trial of caching endpoint z positions and walking z
incrementally measured neutral-to-slower and was reverted. Keep the
no-known-gaps and long-run evidence current.
