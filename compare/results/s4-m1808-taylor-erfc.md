# S4-M1808 Taylor erfc for the Half-Shape Incomplete Gamma

Date: 2026-11-20

## Gap

The skew-normal and wrapped skew-normal CDF/quantile paths evaluate
`Q(0.5, x) = erfc(√x)` through the generic incomplete-gamma series or
continued fraction, which cost about 43-48 ns and dominate the wrapped
skew-normal evaluation. The wrapped skew-normal CDF measured 2.79-2.91M
calls/s and the quantile 0.49-0.54M.

## Change

`gammaIncompleteP/Q` now dispatch `a == 0.5` (f64) to:

- `gammaHalfErfTaylor(x)` for `x <= 4.5`: the alternating erf Taylor series in
  `√x`, which needs no log or exponential. The cancellation is bounded by
  `e^x` ulps (about 9e-15 at the switch point).
- the Mills-ratio `normUpperTailF64` for `x >= 18` (`Q = 2·Q_normal(√(2x))`),
  where the absolute error is below 1e-17.
- the generic continued fraction in between, where it already converges fast.

The generic paths are unchanged for every other shape.

## Accuracy

A 236,538-point sweep over `alpha ∈ [0.1, 20]` and `z ∈ [-8, 8]` compared
`skewNormalCdf` against the previous implementation: maximum absolute
difference `1.44e-15`.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal cdf` | 2.789, 2.815, 2.883, 2.909 | 3.104, 3.131, 3.302, 3.335 |
| `wrapped skew-normal quantile` | 0.487, 0.523, 0.536 | 0.507, 0.537, 0.543 |
| `skew-normal quantile` | 2.100, 2.106, 2.236 | 2.180, 2.187, 2.325 |
| `skew-normal cdf` | 11.308, 11.331, 11.332, 11.862 | 11.327, 11.336, 11.362, 11.872 |

The wrapped skew-normal CDF gains about +11-15%; both quantiles gain a
consistent +3-4%; the plain skew-normal CDF is unchanged (it does not use
the half-shape incomplete gamma in its bench range). Checksums are unchanged.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest row.
