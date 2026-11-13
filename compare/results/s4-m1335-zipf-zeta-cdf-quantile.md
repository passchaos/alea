# S4-M1335 — Zipf/Zeta CDF and quantile diagnostics

## Goal

Complete the discrete diagnostics surface with CDF and quantile support for the
rank distributions:

- `zipfCdf(k, n, exponent)` / `zipfQuantile(q, n, exponent)` for support
  `1..n` (finite `n`, or `n = +∞` when `s > 1`),
- `zetaCdf(k, exponent)` / `zetaQuantile(q, exponent)` for infinite support,
- `Zipf(T)` / `Zeta(T)` and `VectorZipf` / `VectorZeta` `cdf` / `quantile`
  methods.

## Implementation

### Generalized harmonic number

The Zipf CDF is `H(k, s) / H(n, s)` with
`H(x, s) = Σ_{j=1}^{x} j^{-s}`. `generalizedHarmonicNumber` sums the first 128
terms directly and then applies Euler–Maclaurin from 129 to `x`:

`H = H_128 + ∫_129^x t^{-s}dt + (129^{-s} + x^{-s})/2 − Σ c_r (x^{-s-2r+1} − 129^{-s-2r+1})`

with `c_r = B_{2r}/(2r)!·(s)_{2r-1}` and eight Bernoulli terms. The 128-term
prefix keeps the asymptotic corrections below double-precision resolution for
every `s ≥ 0`, so no Riemann zeta function is needed for finite support. `s >
1000` returns 1 (the remaining terms underflow).

### Infinite support

`riemannZetaApprox(s)` for `s > 1` uses the same 128-term prefix plus the
Euler–Maclaurin tail from 129 to infinity. `n = +∞` is accepted only for
`s > 1`, matching the `Zipf`/`Zeta` constructors.

### Quantiles

Deterministic bisection over the integer support; infinite support doubles the
upper bound until the CDF covers `q`. Quantiles above 2^53 are returned as +∞
because integer support values are no longer exactly representable.

### Sampler changes

`Zipf(T)` now stores its support bound `n` instead of reconstructing it from the
normalizer approximation, so `nValue()` is exact and the CDF normalizer is not
polluted by the sampler's inverse-CDF approximation. Scalar and vector sampler
types expose `cdf(k)` / `quantile(q)` delegating to the free helpers.

## Tests added (2 new, total 890)

1. `zipfCdf and zipfQuantile match generalized harmonic values` — exact
   `H_10 = 7381/2520` values, the Euler–Maclaurin path for `s = 0.5` and
   `s = 1` against 1,000-term direct sums, smallest-covering quantiles,
   endpoints, invalid parameters, and f32 support.
2. `zetaCdf and zetaQuantile match Riemann zeta values` — `1/ζ(2)` and
   `(1 + 1/4 + 1/9)/ζ(2)`, `s < 1` rejection, `q = 1 → +∞`, quantile
   round-trips, and sampler/vector method delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds Zipf(40, 1.5) and Zeta(2.5) quantile
  round-trips.
- The long-run discrete block adds 10,000,000-sample empirical CDF gates for
  Zipf(40, 1.5) at k = 2, 4, 8 and Zeta(2.5) at k = 1, 3, 8. Observed:
  zipf(2) `0.588872` vs `0.588985`, zeta(1) `0.745653` vs `0.745441`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` in about 10.4 seconds.

## Validation

- `zig build test` passes 890/890 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Deviations and notes

- The helpers are diagnostics paths: each CDF evaluation costs a 128-term
  prefix plus eight Euler–Maclaurin corrections, and quantiles use bisection.
- Quantiles above 2^53 return +∞; finite-support `n` is limited to 2^53 for the
  same integer-representability reason.
- Very large exponents (`s > 1000`) short-circuit to the point mass at 1,
  which is exact to f64 resolution.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
additional continuous families, or newly discovered core gaps.
