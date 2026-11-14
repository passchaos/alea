# S4-M1466 Gamma-Poisson Mixture for Huge Negative-Binomial Counts

Date: 2026-11-14

## Problem

`negativeBinomialFrom` loops once per success, so `negativeBinomial(rng, 1e9,
0.5)` needs 1e9 geometric draws per sample (seconds), and `1e18` is
effectively infinite. The tiny-p case also overflowed the `u64` failure sum
because the saturation branch added `maxInt` per success.

## Change

- Added `negativeBinomialMixtureFrom`: for `successes >= 2^20`, draw
  `lambda ~ Gamma(successes, (1-p)/p)` and return `Poisson(lambda)` — the exact
  gamma-Poisson mixture, `O(1)` draws.
- If the mixture mean reaches the Poisson maximum (`1.844e19`), the count
  saturates to `maxInt(u64)` because the true mean exceeds the representable
  range.
- `NegativeBinomial.sample`/`sampleFrom`/`fill`/`fillFrom` route through the
  mixture; the per-success loop stays for smaller counts, so their streams are
  unchanged.

## After

| `r` | `p` | expected mean | measured |
| --- | --- | --- | --- |
| `2^20` | 0.5 | 1,048,576 | 1.048584e6 |
| `1e9` | 0.5 | 1e9 | 1.000000e9 |
| `1e18` | 0.5 | 1e18 | 1.000000e18 |
| `2^20` | 1e-15 | 1.05e21 | saturates to 1.844674e19 |

## Validation

- New `negative binomial huge success counts use the mixture` test covers the
  mean, a single 1e9-success draw, the saturation edge, and a bulk fill.
- `zig build test --summary all` passes 915/915 tests (native `alea-tests`
  896/896), `distcheck`, `statcheck`, and the 10M long run pass, and the full
  16MiB benchmark suite keeps all 457 checksums identical.
