# S4-M1804 Tighter von Mises Sine-Sum Cutoff

Date: 2026-11-20

## Gap

S4-M1784 sized the von Mises sine sum as
`min(κ + 6√κ + 10, 8.5√κ + 40)`, which gives 29 terms for `κ = 5` although
the Bessel ratios are already below `1e-14` past `k ≈ 18`. Both the quantile
cache (a per-call sum over `k_sum` terms) and the direct CDF paid for the
extra terms; the quantile measured 3.12-3.42M quantiles/s and the CDF
9.42-9.66M calls/s.

## Change

The sum cutoff is now `min(κ + 4.5√κ + 8, 8.5√κ + 40)` in both the cache and
the direct CDF; the continued-fraction start (`κ + 6√κ + 16`) is unchanged,
and the second term keeps the large-`κ` cost identical.

## Accuracy

A 439,852-point sweep over `κ ∈ [0.01, 1e4]` and `d ∈ (-π, π)` (step 0.0023)
compared the tightened CDF against the previous implementation: maximum
absolute difference `2.22e-16` (one ulp).

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `von mises quantile` | 3.124, 3.311, 3.416 | 3.611, 3.629, 3.632 |
| `von mises cdf` | 9.416, 9.630, 9.663 | 10.234, 10.482, 10.531 |

About +10-16% on the quantile and +9% on the CDF, with unchanged checksums.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest row.
