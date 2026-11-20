# S4-M1801 Direct-Form Ex-Gaussian Term

Date: 2026-11-20

## Gap

The ex-Gaussian CDF formed its exponential term in log space:
`term = exp(exponent + log Φ(w))`. In the ordinary parameter range this
costs a `log` and a `logΦ`, and the combined eval then recomputed `Φ(w)`
separately for the density derivative. The quantile measured 2.59-3.04M
quantiles/s and `exGaussianCdf` about 17.2 ns.

## Change

Both `exGaussianCdfImpl` and `exGaussianEvalF64` now use the direct form
`term = exp(exponent) · Φ(w)` whenever `w > -10` and the exponent is inside
the representable exponential range (`-745 < exponent < 700`). That reuses
the `Φ(w)` the derivative already needs and skips the log; the log-space
branch remains for the far tail and extreme scales where the direct product
would underflow or overflow.

## Measurements

Same-host A/B with two separately built binaries (`ReleaseFast -Dcpu=native`,
`-- 16777216` for the quantile row), alternating old/new:

| Row | Before | After |
| --- | --- | --- |
| `ex-gaussian quantile` | 2.590, 2.901, 3.041M/s | 4.394, 4.735, 4.735M/s |
| `exGaussianCdf` (direct probe) | 17.2 ns | 11.5 ns |

About +55% on the quantile row and +33% on the public CDF, with an unchanged
quantile checksum.

## Correctness audit

Round-trip over 2000 probabilities for `(mu, sigma, tau) = (0,1,1),
(0,0.5,2), (2,2,0.5), (-1,0,1), (0,3,0.1)`: worst `|CDF(q) − p|` is
`2.22e-15`, unchanged from the log-space version (the direct product differs
only by rounding).

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest row, followed by the inverse-Gaussian and von Mises
quantiles.
