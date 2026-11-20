# S4-M1794 Halley Step for the Wrapped Normal Quantile

Date: 2026-11-20

## Gap

The wrapped normal quantile ran safeguarded Newton on the cached image-sum
CDF. The density derivative is `Σ −z·φ(z)/σ²`, which is one extra multiply
and subtract per image in the loop that already accumulates `φ(z)`. The row
measured 3.40-3.73M quantiles/s.

## Change

`WrappedNormalCdfCache.eval` now also accumulates the density derivative and
returns it; the quantile takes a Halley step (`2 f f' / (2 f'^2 − f f'')`)
when the CDF is representable and the denominator is positive and finite,
keeping Newton as the base and bisection as the fallback. Works for f32 and
f64 since the cache is generic.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped normal quantile` | 3.397, 3.514, 3.734 | 4.062, 4.238, 4.258 |

About +18% with an unchanged checksum.

## Correctness audit

Round-trip over 2000 probabilities for `(mu, sigma) = (0, 0.5), (0.4, 1),
(-2, 2), (3, 3), (0, 9.5)`: worst `|CDF(q) − p|` is `7.16e-13` for the
concentrated cases and `5.00e-10` for `sigma = 9.5` (the same as before the
change; that branch uses the uniform shortcut). No spurious roots.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest model row, followed by the ex-gaussian and Rice
quantiles.
