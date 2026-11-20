# S4-M1796 Bound the Wrapped Skew-Normal Image Loop

Date: 2026-11-20

## Gap

`WrappedSkewNormalCdfCache` looped over every image in `[-k_max, k_max]`
(seven for `sigma = 1`) and evaluated its term table for all of them. Images
whose whole `z`-range lies beyond the 6.5-sigma saturation band on the same
side as their endpoint are always skipped by the existing per-evaluation test,
so four of the seven images were pure loop and term-table overhead. The
wrapped skew-normal quantile row measured 0.44-0.49M quantiles/s.

## Change

`init` now computes the inclusive image range `[k_lo, k_hi]` from the
parameter-only endpoint coordinates:

- active when `L_k = (−π−μ)/σ + k·2π/σ < 6.5` and
  `R_k = (π−μ)/σ + k·2π/σ > −6.5`,
- `k_lo = max(−k_max, floor((−6.5 − upper_z0)/stride))`,
- `k_hi = min(k_max, ceil((6.5 − lower_z0)/stride))`.

`ensureTerms` and `eval` loop only over that range, with the term-table index
starting at `k_lo + k_max` so the existing indexing is preserved. The
per-evaluation skip test stays in place for the partially saturated boundary
images.

The same bound was applied to the public `wrappedSkewNormalCdfF64` loop
(with its tighter 9-sigma threshold) and measured neutral (3.41/3.41/3.13M ->
3.31/3.43/3.43M), so that part was reverted; the quantile cache keeps it.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal quantile` | 0.442, 0.493, 0.494 | 0.584, 0.595, 0.607 |

About +23% with an unchanged checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
is now about 0.6M quantiles/s and the next slowest rows are the skew-normal
quantile (1.48M) and Rice (2.65M).
