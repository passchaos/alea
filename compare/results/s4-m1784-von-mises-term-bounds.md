# S4-M1784 Tighter von Mises Fourier Term Bounds

Date: 2026-11-20

## Gap

`vonMisesRelativeCdf` (and the `VonMisesCdfCache` used by the quantile) sized
its backward Bessel-ratio continued fraction with
`max(64, κ + 10√κ + 40)` terms and its sine sum with
`max(64, 8.5√κ + 40)`. The 64/40 floors dominate for small and moderate `κ`:
`κ = 5` ran 68 recurrence steps and summed 64 sines even though the Bessel
ratios are below `1e-20` past `k ≈ 16`. The von Mises CDF row measured
3.4-4.7M calls/s and the quantile 1.4-1.6M calls/s.

## Change

Both the direct CDF and the cached quantile path now size the recurrence from
the decay band `κ + 6√κ`:

- `k_total = ceil(κ + 6√κ + 16)` (continued-fraction start),
- `k_sum = ceil(min(κ + 6√κ + 10, 8.5√κ + 40))` (sine sum; the second term
  keeps the old large-`κ` cost),
- `VonMisesCdfCache.max_terms` 128 -> 192 so the cache still covers the same
  `κ` range (up to about 120).

The emitted values are unchanged at the printed checksum resolution; the
sampler and the `κ > 1e4` asymptotic path are untouched.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `von mises cdf` (κ=5) | 4.601, 4.616, 4.683 | 9.940, 9.969, 10.094 |
| `von mises quantile` (κ=5) | 1.415, 1.459, 1.550 | 2.857, 2.861, 2.867 |

That is about 2.17x for the CDF and 1.87x for the quantile. A second, noisier
window still showed the CDF at 6.8-10.0M versus 3.4-3.5M. A direct
`vonMisesQuantile` timing probe across `κ` measured 723 -> 412 ns at `κ = 5`,
1065 -> 877 ns at `κ = 40`, and parity within noise at `κ = 80-100`.

## Accuracy

The tightened bounds were compared against a high-term reference (the same
Fourier sum with `κ + 30√κ + 250` terms) over `κ ∈ [0.01, 1e4]` and
`d ∈ (-π, π)` (grid step 0.0021, excluding the `1e-3` antipodal band that
deliberately uses the dedicated tail series): worst absolute difference
`5.55e-16`. In the antipodal band the tail series and the Fourier reference
differ by about `2e-13`, which is the pre-existing formulation split rather
than a truncation change.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok` (including the von Mises sampler/CDF
  gates).
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current and continue the Alea-only slow
rows (wrapped skew-normal CDF, skew-normal CDF, wrapped skew-normal quantile).
