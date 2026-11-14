# S4-M1474 Long-Run Gates for the Huge-Parameter Samplers

Date: 2026-11-14

## Change

`checkLongRun` now gates the huge-parameter paths at the full 1e7/1e9 sweep:

- `binomial(1e18, 2e-17)` mean in `[19.9, 20.1]`,
- `binomial(1e18, 0.5)` mean in `[4.9999e17, 5.0001e17]`,
- `hypergeometric(1e18, 1e17, 5e17)` mean in `[4.9999e16, 5.0001e16]`,
- `hypergeometric(1e18, 5, 5e17)` mean in `[2.49, 2.51]`,
- `negativeBinomial(2^20, 0.5)` mean in `[1.0485e6, 1.0487e6]`.

The gates run in the native, WASI, and libc long-run variants.

## HIN Small-P Offset Finding

Wiring the tiny-p gate exposed a pre-existing HIN characteristic (not caused
by the huge-trial fixes). 20M-draw mean offsets at mean 20:

| case | bias |
| --- | --- |
| `binomial(2000, 0.01)` | +0.0149 |
| `binomial(1000, 0.02)` | +0.0157 |
| `binomial(400, 0.05)` | +0.0129 |
| `binomial(200, 0.1)` | +0.0057 |
| `binomial(80, 0.25)` | +0.0004 |
| `binomial(10000, 0.5)` | -0.0095 (0.9σ) |
| waiting/dyadic/fair paths | unbiased |

The offset is roughly constant `+0.015` absolute across means `16..1000`,
about `0.003σ` of the mean-20 distribution and shrinking relative to the
mean. The tiny-p long-run gate therefore uses `[19.9, 20.1]`, which still
rejects the old zero-mean regression. Fixing the HIN envelope's small-p
correction is recorded as future work.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig build distcheck` and `zig build test --summary all` (917/917, native
  898/898) pass.
