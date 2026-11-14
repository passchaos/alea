# S4-M1470 Hypergeometric Inverse-Transform Init for Edge-Shaped Huge Populations

Date: 2026-11-14

## Problem

`Hypergeometric.init(1e18, 1, 5e17)` hung inside
`fractionOfProductsOfFactorials`, which loops from `min_all` to `max_all`
(about 5e17 iterations) to compute the inverse transform's initial PMF. The
same loop also loses accuracy for huge arguments.

## Change

- For product lengths at or below 1e6, keep
  `fractionOfProductsOfFactorials`, so moderate-parameter streams are
  bit-identical.
- For longer products, use the `log1p` limit:
  `exp(n1 · log1p(−k/N))` when `k < n2`, and
  `exp((N−k) · log1p(−n2/N))` otherwise. The error is `O(mean²/length)`,
  negligible in the inverse-transform regime (mode within 10 of the lower
  support bound).

## After

- `Hypergeometric.init(1e18, 1, 5e17)` returns immediately with the
  `inverse_transform` method.
- 20,000-draw means for `(1e18, 1, 5e17)`, `(1e18, 2, 5e17)`, and
  `(1e18, 5, 5e17)` are `0.499200`, `0.997050`, and `2.497500` against
  `0.5`, `1.0`, and `2.5`.
- The full 16MiB benchmark suite keeps all 457 checksums identical.

## Validation

- New `hypergeometric edge-shaped huge populations use the inverse transform`
  test checks the method selection and the means.
- `zig build test --summary all` passes 917/917 tests (native `alea-tests`
  898/898), `distcheck`, `statcheck`, and the 10M long run pass.
