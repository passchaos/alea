# S4-M1795 Combined Ex-Gaussian Evaluation and Halley Step

Date: 2026-11-20

## Gap

The ex-Gaussian quantile called `exGaussianCdf` and `exGaussianPdfF64`
separately each iteration, duplicating the `w = z − σ/τ`, exponent, and
`normLogCdf` work, and then took a plain Newton step. The density derivative
is cheap once those terms exist: `f · (−1/τ + φ(w)/(σ·Φ(w)))`. The row
measured 2.61-2.65M quantiles/s.

## Change

`exGaussianEvalF64` returns the CDF, density, and density derivative in one
pass, reusing the `exp(...)·Φ(w)` term for all three (the `σ = 0` shifted
exponential branch returns the closed-form derivative `−f/τ`). The quantile
loop uses the combined eval and takes a Halley step when the CDF is
representable and the denominator is positive and finite, with Newton as the
base and bisection fallback.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `ex-gaussian quantile` | 2.611, 2.653, 2.653 | 3.051, 3.052, 3.053 |

About +16% with an unchanged checksum.

## Correctness audit

Round-trip over 2000 probabilities for `(mu, sigma, tau) = (0,1,1),
(0,0.5,2), (2,2,0.5), (-1,0,1), (0,3,0.1)`: worst `|CDF(q) − p|` is
`2.22e-15`, the same level as before the change.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

The wrapped skew-normal quantile remains the slowest row; its image loop can
be bounded to the images that are not always saturated.
