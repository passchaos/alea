# S4-M1786 Wrapped-Normal Start for the Wrapped Skew-Normal Quantile

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile seeded its safeguarded Halley loop with the
skew-normal quantile, wrapped into `(-π, π]`. That start needed only 3.27
image-sum iterations, but the skew-normal quantile solve itself cost about
1.0 µs (5.7 Halley iterations of its own), and with the S4-M1785 Owen T work
the image-sum evaluation became cheap enough that the expensive start
dominated the call. The row sat at 0.40M quantiles/s.

## Change

The start is now the wrapped normal quantile `wrap(mu + sigma * probit(p))`,
which is a `probit` call and a wrap. It costs a couple of extra Halley
iterations (5.21 vs 3.27 on the 100k-point sweep) but removes the ~1 µs
skew-normal solve. The iteration loop, bracket safeguards, and tolerances are
unchanged.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal quantile` | 0.400, 0.400, 0.405 | 0.450, 0.453, 0.460 |

About +13% on the benched parameters (`mu = 0.4`, `sigma = 1`, `alpha = 2`).
A direct timing probe across shapes also improved at every measured `alpha`:
2353 -> 2055 ns at `alpha = 0.5`, 2843 -> 2566 ns at `alpha = 2`, and
3744 -> 3525 ns at `alpha = 6` (larger shapes are covered by S4-M1787).
The checksum is unchanged at the printed resolution.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

The large-`alpha` wrapped skew-normal path still falls back to adaptive
Simpson through Owen T's `|a| <= 6` far-tail guard; that is the next gap.
