# S4-M1802 Direct-Form Rice Density

Date: 2026-11-20

## Gap

`ricePdfImpl` computed the density entirely in log space:
`log x − log σ² − (x²+ν²)/(2σ²) + logI₀(xν/σ²)` followed by an `exp`. The
quantile calls it every iteration, so two logs, the log-Bessel series, and
the final exponential dominated the per-iteration cost. The Rice quantile
measured 2.73-2.96M quantiles/s after S4-M1800.

## Change

For the moderate range (`u = x·ν/σ² <= 30` and `exponent > -700`) the density
uses the direct form `(x/σ²)·exp(exponent)·I₀(u)` — one `exp` plus the I₀
power series. The log-space path remains for larger Bessel arguments or
extreme exponents, where the direct product could underflow or overflow. The
product is bounded by the density's own peak, so no new overflow is
introduced.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `rice quantile` | 2.726, 2.785, 2.959 | 3.127, 3.157, 3.395 |

About +15% with an unchanged checksum.

## Correctness audit

Round-trip over 2000 probabilities for `nu ∈ {0.1, 1, 5, 20}`: worst
`|CDF(q) − p|` is `7.50e-12`, identical to the log-space version.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest row, followed by the inverse-Gaussian and von Mises
quantiles.
