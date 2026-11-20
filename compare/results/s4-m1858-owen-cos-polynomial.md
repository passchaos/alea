# S4-M1858 Vectorized Cos Polynomial for the Owen Geometry Build

Date: 2026-11-20

## Gap

`owenTGlTable12` and `owenTGlTable` build the Gauss-Legendre geometry with
12 and 24 `@cos` calls. Each libm `@cos` costs about 3.3 ns on this host,
so a runtime-shape call pays 40-80 ns before the Owen quadrature even
starts. The benchmark rows used literal shapes (`alpha = 2`), which the
compiler folds at comptime, hiding the gap: the public skew-normal CDF
measured 38.4 ns/call with a literal shape but 86.8 ns/call with a
runtime shape.

## Change

The geometry build now evaluates `cos(theta)` from `z = theta^2` through a
degree-7 minimax polynomial in `t = z / 0.98792265710413907 - 1`,
four angles at a time with `@Vector(4, f64)` FMAs. The polynomial covers
`theta in [0, atan(6)]`, the full domain of both the 12-point and 24-point
rules; the generic `|alpha| > 6` Owen path keeps its inline `@cos`
quadrature. Constant shapes still fold at comptime, so the literal
benchmark rows are unaffected.

## Accuracy

- The polynomial's worst absolute `cos` error over `[0, atan(6)]` is
  5.6e-16 (edge relative error 2.5e-15), so `inv_cos2` moves by at most a
  few ulps.
- A 393,060-point public CDF grid (plain skew `alpha` from -2 to 2,
  `z` from -40 to 40; wrapped skew `sigma` in {0.2, 0.5, 1, 2, 5}) shows
  **zero** changed values at 17 significant digits against the libm-cos
  binary.
- Full tests 996/996, including the skew reference values, the wrapped
  round-trip contract grid, and the direct-stream-shape tests.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(the same bench rows on both sides; only the geometry build differs),
three alternating pairs:

| Row | Baseline (M/s) | Candidate (M/s) |
| --- | --- | --- |
| `alea skew-normal cdf runtime` (new) | 11.623, 11.073, 11.293 | 14.633, 13.932, 14.345 |
| `alea skew-normal quantile runtime` (new) | 3.749, 3.215, 3.606 | 3.319, 3.633, 3.757 |

The runtime CDF gains about 27% (median 11.3M -> 14.3M) with every
candidate run above every baseline and the unchanged checksum `1643.182`.
The runtime quantile is flat within the loaded-host noise band because the
geometry build is a smaller share of its ~270 ns call. The literal-shape
rows (`alea skew-normal cdf` 26.9-29.8M, `alea skew-normal quantile`
3.9-4.6M) are unchanged, as expected for comptime-folded shapes.

The two `runtime` rows are new bench coverage: the shape is read through a
volatile pointer so the per-call geometry build is measured, matching the
workflow real callers with runtime parameters use.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.

## Next Bar

Finish the 50M long-run refresh and keep the 1e9 background run going;
the large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
