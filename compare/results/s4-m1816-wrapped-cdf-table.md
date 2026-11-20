# S4-M1816 Per-Call Owen T Table in the Public Wrapped Skew-Normal CDF

Date: 2026-11-20

## Gap

`wrappedSkewNormalCdfF64` evaluates two skew-normal tail terms per image
(point and endpoint) with the same shape, but each `owenT` call rebuilt the
24-node Gauss-Legendre geometry. The row measured 3.47-3.85M calls/s.

## Change

The function builds one `OwenTGlTable` per call when `alpha != 0` and
`|alpha| <= 6` (the shapes that reach the fixed rule) and uses the
table-aware `skewNormalUpperTailZWithGlTable` /
`skewNormalCdfZWithGlTable` for both the point and endpoint terms. Every
other branch and the log-space paths are unchanged.

## Accuracy

A 107,676-point sweep over `alpha ∈ [0.1, 8]` and `x ∈ (-π, π]` compared
`wrappedSkewNormalCdf` against the previous implementation: maximum absolute
difference `2.22e-16` (one ulp).

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal cdf` | 3.474, 3.729, 3.852 | 4.048, 4.071, 4.132 |

About +9-15% with an unchanged checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
