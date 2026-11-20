# S4-M1810 Wilson-Hilferty Start for the Rice Quantile

Date: 2026-11-20

## Gap

The Rice quantile seeded its safeguarded Newton loop with `nu + sigma·z`
(the normal quantile), which is a poor start for the skewed Rician shape
(the harness shape `nu = sigma = 1` is strongly right-skewed). The row
measured 3.35-3.56M quantiles/s after the S4-M1800/M1802 work.

## Change

For `nu > 0` the start is now the Wilson-Hilferty cube-root approximation of
the underlying noncentral chi-square: with `lambda = (nu/sigma)²` and
`df_eff = 2 + lambda`,

```
t = 1 − 2/(9·df_eff) + z·sqrt(2/(9·df_eff))
x0 = sigma·sqrt(df_eff·t³)
```

falling back to the normal start when `t <= 0`. The `nu = 0` Rayleigh start
and the large-noncentrality Gaussian branch are unchanged.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `rice quantile` | 3.354, 3.494, 3.564 | 3.778, 3.964, 4.026 |

About +10-13% with an unchanged checksum.

## Correctness audit

Round-trip over 2000 probabilities for `nu ∈ {0.1, 1, 5, 20}`: worst
`|CDF(q) − p|` is `7.82e-12`, the same level as before (`7.50e-12`).

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest row.
