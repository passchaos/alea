# S4-M1799 Share the Owen T Geometry Table with the Wrapped Cache

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile evaluates `T(z, alpha)` with a fixed shape
inside its image loop and endpoint-term setup. It rebuilt the Gauss-Legendre
node geometry on every call, just like the plain skew-normal quantile before
S4-M1798, leaving the row at 0.52-0.53M quantiles/s.

## Change

`WrappedSkewNormalCdfCache` now builds one `OwenTGlTable` in `init` when
`|alpha| <= 6` and `alpha != 0`, and the endpoint-term setup and the per-image
evaluation use `skewNormalUpperTailZWithGlTable` /
`skewNormalCdfZWithGlTable`. Every other branch (far tail, asymptotic lower
tail, `alpha = 0`, `|alpha| > 6`) matches the previous path.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating base/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal quantile` | 0.524, 0.531, 0.531 | 0.545, 0.560, 0.560 |

About +5% with every new run above every old run and an unchanged checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.
- Extreme-shape round-trip audit: wrapped skew-normal `alpha = 6` and
  `alpha = 20` both stay at `8.05e-11`, and every other family matches the
  S4-M1797 results.

## Next Bar

Keep the no-known-gaps comparison current; the remaining slow rows are the
wrapped skew-normal quantile (about 0.55M), Rice (2.65M), and the extreme
`beta(0.1,0.1)` / `gamma(0.05,1)` CDF-resolution limits noted in S4-M1797.
