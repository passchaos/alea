# S4-M1534 Mills-Ratio Series for the Normal Upper Tail

Date: 2026-11-15

## Problem

S4-M1532 resolved the lower-tail cancellation in `normCdf`, but the
Abramowitz-Stegun erf complement term has growing relative error in the deep
tail because it is an absolute-error approximation. At `x = -37` it returned
`6.638e-300` instead of the true `5.73e-300` (~16% relative error), and
`probit(normCdf(-37))` was off by `4e-3`.

## Change

For `|x| ≥ 6`, `normCdf` now uses the Mills-ratio asymptotic series

```
Q(x) = φ(x)/x · Σ_{k≥0} (-1)^k (2k-1)!! / x^{2k}
```

with adaptive truncation at the smallest term. The series error is about
`exp(-x²/2)` relative (`~1.5e-8` at `x = 6`, below `1e-70` at `x = 37`).
Below `|x| = 6` the existing A&S complement form is kept, so mid-range
values and existing snapshots are unchanged. f32 uses the same series with
f32 arithmetic.

## Before/After

| x | A&S complement | Mills series | reference |
| --- | --- | --- | --- |
| -8.5 | 9.597e-18 | 9.4795e-18 | 9.480e-18 |
| -12 | 1.832e-33 | 1.77648e-33 | 1.776e-33 |
| -20 | 2.97e-89 | 2.75362e-89 | 2.754e-89 |
| -37 | 6.638e-300 | 5.7256e-300 | 5.73e-300 |

`probit(normCdf(x))` round-trip in the tail:

| x | before | after |
| --- | --- | --- |
| -6 | 5.8e-4 | 1.5e-9 |
| -8.5 | 1.4e-3 | 4.7e-9 |
| -12 | 2.5e-3 | 1.2e-8 |
| -20 | 3.8e-3 | 9.1e-9 |
| -37 | 4.0e-3 | 2.0e-9 |

The large-shape gamma lower-tail quantile also tightens:
`gammaQuantile(1e-300, 1e6, 1)` returns `963408.19` and its CDF round-trips
to `1e-300` within `4.3e-12` relative.

## Validation

- `normCdf resolves the lower tail below 1e-16` now checks the Mills-series
  values at `-8.5` and `-12` at `1e-20`/`1e-36` absolute tolerance, plus the
  subnormal `-38` value and the SIMD/f32 paths.
- `zig build test --summary all` passes 942/942 (native `alea-tests`
  923/923).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
