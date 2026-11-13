# S4-M1338 — Core continuous CDF and quantile diagnostics

## Goal

Add CDF and quantile diagnostics for the core continuous families that
previously had only moments and sampling:

- Exponential, Log-normal, Half-normal, Chi, Erlang, and Maxwell,
- free helpers `exponentialCdf` / `exponentialQuantile`, `logNormalCdf` /
  `logNormalQuantile`, `halfNormalCdf` / `halfNormalQuantile`, `chiCdf` /
  `chiQuantile`, `erlangCdf` / `erlangQuantile`, `maxwellCdf` /
  `maxwellQuantile`,
- matching `cdf` / `quantile` methods on each sampler type.

## Implementation

- Exponential: `1 − e^{−λx}`; rate 0 is the improper all-at-infinity limit and
  rate +∞ is the point mass at 0.
- Log-normal: `Φ((ln x − μ)/|σ|)`; the absolute value matches the sampler's
  reflected-normal semantics for negative `σ`, and `σ = 0` is the point mass at
  `e^μ`.
- Half-normal: `2Φ(x/σ) − 1`; `σ = 0` is the point mass at 0.
- Chi: `P(k/2, x²/2)` via `gammaIncompleteP`; quantile is
  `√chiSquaredQuantile(p, k)`.
- Erlang: validates a positive integer shape and delegates to the Gamma
  helpers; `scale = 0` is the point mass at 0.
- Maxwell: `P(σχ₃ ≤ x) = P(3/2, x²/(2σ²))`; quantile is
  `σ·√chiSquaredQuantile(p, 3)`.

The normal-derived helpers inherit the `normCdf` / `probit`
Abramowitz–Stegun accuracy (~1e-7), which is documented in the guide; the
Gamma-derived helpers keep the incomplete-gamma series accuracy.

## Tests added (1 new, total 892)

`core continuous CDF and quantile helpers match known values` covers
`1 − e^{−2}`, `Φ(1)`, `2Φ(1) − 1`, `P(3/2, 1/2)`, the Erlang
`1 − 3e^{−2}` form, the Chi/Maxwell identity, quantile round-trips at
`p = 0.1/0.5/0.9`, degenerate `rate = 0/∞` and zero-scale point masses,
negative log-stddev parity, invalid parameters, f32 support, and sampler-method
delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds quantile round-trips for all six families
  (the normal-derived ones use a `1e-5` band for the A&S erf accuracy).
- The long-run continuous block adds 10,000,000-sample empirical CDF gates for
  `Exponential(rate=2)` at `x = 0.25/0.5/1` and `LogNormal(0, 0.5)` at
  `x = 0.5/1/2`. Observed: exponential(0.5) `0.632073` vs `0.632121`,
  log-normal(1) `0.499643` vs `0.500000`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 892/892 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
the remaining advanced continuous families (BetaPrime, SkewNormal, PERT,
inverse-Gaussian, Rice/Nakagami), or newly discovered core gaps.
