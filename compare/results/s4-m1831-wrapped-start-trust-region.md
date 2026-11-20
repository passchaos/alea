# S4-M1831 Trust-Region Start for the Wrapped Skew-Normal Quantile

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile sharpened its wrapped-normal start with a
single Newton step on the standardized skew-normal CDF. A per-`p` bucket
profile showed the lower tail averaging 5.65 iterations (p in 0.05-0.3) and
6.28 (p < 0.05) against 2.98 on the upper side. The cause: in the left tail
the density at the start is tiny (about 0.02 at `z = −0.88`), so the raw
Newton correction was 8+ radians; the wrap then folded it to the opposite
side and the solve restarted from far away.

## Change

The start step is now a Halley step (the density pair already carries the
second derivative, so it costs almost nothing extra), capped at a one-radian
trust radius, and the result is accepted only if it stays inside the wrapped
domain `((-π−μ)/σ, (π−μ)/σ)`. A step outside the domain would wrap to the
other side, which is never an improvement.

## Measurements

Iteration profile over the bench's 1000-probability sweep
(`wrappedSkewNormalQuantile(p, 0.4, 1, 2)`):

| `p` bucket | Mean iterations before | After |
| --- | --- | --- |
| `p < 0.05` | 6.28 | 7.04 |
| `0.05-0.3` | 5.65 | 3.78 |
| `0.3-0.7` | 3.94 | 3.56 |
| `0.7-0.95` | 3.00 | 2.98 |
| `p > 0.95` | 3.50 | 3.56 |

The overall mean drops from 4.27 to 3.64 iterations. The far-tail bucket
regresses by about 0.8 iterations (5% of calls, where the trust radius
overshoots the small true displacement) while the moderate lower tail loses
almost two.

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal quantile` | 0.940, 0.973, 0.982 | 1.119, 1.106, 1.090 |

Every paired run favors the change; the median moves from 0.973M to 1.106M
(about +14%) with identical checksums (`4282.426`).

## Accuracy

The S4-M1824 contract grid (`CDF(quantile(p))` over `sigma ∈ {0.2 … 9}`,
`alpha ∈ {−10 … 10}`, seven probabilities): worst round-trip error
5.49796e-11, identical to before this change.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 1.1M quantiles/s. The
remaining cost is the ~3.6 Halley evaluations at about 150 ns each. Keep the
no-known-gaps and long-run evidence current.
