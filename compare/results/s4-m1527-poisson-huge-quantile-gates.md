# S4-M1527 Huge-Lambda Poisson Quantile Inversion Gates

Date: 2026-11-15

## Audit

A standalone probe checked `poissonQuantile` / `poissonCdf` inversion at
`lambda = 1e4, 1e5, 1e6, 1e9, 1e12` for
`q = 1e-6, 0.01, 0.5, 0.99, 1 - 1e-6`. In every case the returned integer
`k` satisfied `CDF(k) >= q` and `CDF(k-1) < q`. The CDF gap narrowed with
`lambda`, consistent with the incomplete-gamma Wilson-Hilferty fallback's
`O(1/a)` error:

| lambda | q = 0.5, CDF(k) | CDF(k-1) |
| --- | --- | --- |
| 1e4 | 0.502659612 | 0.498670186 |
| 1e5 | 0.500841049 | 0.499579475 |
| 1e6 | 0.500265964 | 0.499867018 |
| 1e9 | 0.500008411 | 0.499995794 |
| 1e12 | 0.500000266 | 0.499999866 |

No bug was found; the huge-lambda Poisson diagnostics were previously gated
only at `lambda = 5`.

## Change

`tools/distcheck.zig` now gates the inversion invariants for
`lambda = 1e6` and `1e12` at five quantiles: `CDF(k) >= q` and
`CDF(k-1) <= q`. Because the Poisson CDF routes through
`gammaIncompleteQ(k+1, lambda)`, this also guards the Wilson-Hilferty
fallback's inversion accuracy at huge shapes.

## Validation

- `zig build distcheck --summary all` passes with the new gates.
- `zig build test --summary all` passes 940/940 (native `alea-tests`
  919/919); no library code changed.

The aggregate `validate-all` refresh is tracked as the following milestone.

## Addendum: WASI Failure Exposed a 32-bit Search Bug

The first `validate-all` run after adding these gates failed the WASI
distcheck with `poisson huge quantile cdf: nan not in [0.000001, 1.000000]`.
`poissonQuantile` used `usize` for its integer search, and on wasm32
(32-bit `usize`) the `lambda > maxInt(usize)/4` guard rejects `lambda = 1e12`.
The same width dependency affected `binomialQuantile` (`n = 1e12` → NaN) and
`negativeBinomialQuantile` (quantiles above `2^32` → inf). The u64 search fix
and its native/WASI regression test are tracked as S4-M1528.

