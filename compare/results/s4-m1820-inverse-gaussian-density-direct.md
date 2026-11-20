# S4-M1820 Direct-Form Inverse-Gaussian Density

Date: 2026-11-20

## Gap

`inverseGaussianPdfF64` computed the density as
`exp(½log(λ/2π) − 1.5log x − λ(x−μ)²/(2μ²x))`, paying a `log(x)` per call in
the quantile's iteration loop. The row measured 4.70-4.77M quantiles/s.

## Change

For `x > 1e-100` with a representable exponent the density uses the direct
form `sqrt(λ/(2π))·e^exponent/(x·sqrt(x))`, replacing the `log(x)` with a
square root and a division. The log-space path remains for tiny `x` or
extreme exponents, where the direct product could underflow or divide by
zero.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `inverse-gaussian quantile` | 4.699, 4.749, 4.767 | 4.954, 5.139, 5.142 |

About +6-9% with an unchanged checksum.

## Correctness audit

Round-trip over 2000 probabilities for `shape ∈ {0.5, 1, 2, 10, 100}` stays
at `3.77e-15`.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
