# S4-M1785 Extend the Owen T Gauss-Legendre Band

Date: 2026-11-20

## Gap

`owenT` used the fixed 24-point Gauss-Legendre rule only for `|h| <= 3`,
sent the far-tail closed form to `|h| >= 3` with `|h·a| >= 6`, and left the
band `3 < |h| <= 6`, `|h·a| < 6` on the adaptive Simpson fallback. The
skew-normal CDF bench sweeps `x ∈ (-4, 4)` with `alpha = 1`, so one eighth of
its calls (`x ∈ (3, 4)`) landed in that band and paid the recursive Simpson
path. The row measured 3.06-3.09M calls/s and the wrapped skew-normal CDF
2.74-2.76M.

## Change

The Gauss-Legendre branch now covers the whole `|h| <= 6`, `|a| <= 6` box,
with the far-tail closed form kept as the cheaper path where it applies
(`|h| >= 3` and `|h·a| >= 6`). Only the dispatch changed; the 24-point rule,
its nodes/weights, and the far-tail formula are untouched.

The rule's accuracy in the new band was checked two ways: a `v = h·tan(theta)`
change of variables converges below `1e-19` there (1 vs 2 vs 4 subintervals),
and the rule matches the adaptive Simpson reference to `8.4e-13` — the
reference's own 1e-12 tolerance, not the rule's error. The Owen T test now
also covers `h ∈ {3.5, 4.0, 4.7, 5.5, 6.0}` with `h·a < 6`.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `skew-normal cdf` | 3.055, 3.061, 3.071 | 11.079, 11.098, 11.152 |
| `wrapped skew-normal cdf` | 2.731, 2.735, 2.767 | 3.114, 3.142, 3.154 |
| `wrapped skew-normal quantile` | 0.385, 0.389 | 0.421, 0.423 |
| `skew-normal quantile` | 1.165, 1.186 | 1.235, 1.236 |

That is about 3.6x for the skew-normal CDF, +14% for the wrapped skew-normal
CDF, and +5-10% for the two quantiles that share the evaluation. Checksums are
unchanged at the printed resolution, and the sampler rows are untouched.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the remaining slow rows are the
wrapped skew-normal quantile and the wrapped skew-normal CDF.
