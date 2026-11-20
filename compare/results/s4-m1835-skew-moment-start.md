# S4-M1835 Moment-Matched Start for the Skew-Normal Quantiles

Date: 2026-11-20

## Gap

Both skew-normal quantiles started from the plain normal quantile
`probit(p)`, which ignores the shape entirely. For `alpha = 1` the
skew-normal median sits at `z = 0.545` rather than 0, and the start error
runs from 0.55 radians at the median to 1.23 in the far left tail. A
per-`p` profile showed the skew-normal quantile averaging 5.12 Halley
iterations (8.94 in the `p < 0.05` bucket) with 10-39% of the steps falling
back from Halley to Newton because the curvature term dominated the guard.

## Change

The start now uses the skew-normal's own mean and standard deviation,
`delta = alpha/sqrt(1 + alpha^2)`, `mean = delta·sqrt(2/pi)`,
`sd = sqrt(1 − 2·delta²/pi)`, so the seed is
`mean + sd·probit(p)` before the usual standardization. This is a few
hoisted flops per call. The plain skew-normal quantile uses it directly;
the wrapped quantile uses it inside the existing wrapped seed and keeps its
Halley pre-step and trust region.

## Measurements

- Skew-normal quantile iteration profile over the bench sweep: mean 5.12 →
  3.14 (the `p < 0.05` bucket drops from 8.94 to 4.00, the centre from 4.79
  to 3.00), and Halley is now accepted on 100% of steps in every bucket.
- Direct `skewNormalQuantile(p, 0, 1, 1)` sweep: 336 ns → 221.8 ns per call
  (about −34%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`): `skew-normal quantile`
  2.658, 2.618, 2.662, 2.837 M/s before and 4.019, 4.271, 4.333, 4.456 M/s
  after (median 2.660M to 4.302M, about +62%) with identical checksums.
- Wrapped skew-normal quantile: 942.6 ns → 856.8 ns per call (about −9%);
  the bench row moves from 0.977, 0.963, 0.987 M/s to 1.104, 1.151,
  1.136 M/s (median +16%) in three alternating pairs.

## Accuracy

- Skew-normal round trip over `alpha ∈ {−10 … 10}` and `p` from 1e-9 to
  `1 − 1e-6`: worst relative error 5.67e-6 at `alpha = 0.5`, `p = 1e-9`,
  the same order as the pre-change 3.85e-6 (`alpha = 3`) — the deep-tail
  behaviour is unchanged by the start.
- Wrapped skew-normal contract grid: worst round-trip error 5.49796e-11,
  identical to before.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The skew-normal quantile is now about 4.3M quantiles/s and the wrapped
skew-normal quantile about 1.14M/s. Keep the no-known-gaps and long-run
evidence current, and revisit the large-hypergeometric codegen gap.
