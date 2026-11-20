# S4-M1788 Drop the Dead Skew-Normal Quantile Bracket Expansion

Date: 2026-11-20

## Gap

`skewNormalQuantileImpl` started its safeguarded Halley loop with a bracket of
`[-40, 40]` and then expanded it with two `skewNormalCdfZ` probes:

```zig
while (skewNormalCdfZ(lo, shape_f) > p_f and expansion < 64) lo -= 1;
while (skewNormalCdfZ(hi, shape_f) < p_f and expansion < 64) hi += 1;
```

The standardized CDF is clamped to `[0, 1]` and saturates at `±40` for every
finite shape (checked for `alpha ∈ {0.5, 2, 10, 1e6, 1e300}`), so for any
`p ∈ (0, 1)` the loops can never expand — they only pay one CDF evaluation
each. That is about 180 ns of the roughly 800 ns call.

## Change

The loops are removed and the fixed `[-40, 40]` bracket is documented as
always sufficient. No numerical path changes: the probes always returned
false.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `skew-normal quantile` | 0.785, 1.116, 1.181 | 1.266, 1.482, 1.499 |

Using the median of the stable runs that is about +27% (1.15 -> 1.48M); the
checksum is unchanged. The wrapped skew-normal quantile no longer calls this
function since S4-M1786, so it is unaffected.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
start can still be sharpened with one cheap skew-normal step.
