# S4-M1344 — Hoyt (Nakagami-q) CDF/quantile diagnostics

## Goal

Add CDF and quantile diagnostics for the Hoyt (Nakagami-q) fading
distribution, completing the fading-family diagnostics alongside Rayleigh,
Nakagami-m, and Rice:

- `hoytCdf(x, q, omega)`,
- `hoytQuantile(p, q, omega)`,
- matching `cdf` / `quantile` methods on `Hoyt`.

## Implementation

With `X = √(σ₁²Z₁² + σ₂²Z₂²)`, `Ω = σ₁² + σ₂²`, and `q = σ₂/σ₁`, the CDF is

`F(x) = 2q/(1+q²) · Σ_{n≥0} c_n · P(2n+1, a·x²)`

where `r = (1−q²)/(1+q²)`, `a = (1+q²)²/(4q²Ω)`,
`c_n = (2n)!/(n!)²·(r²/4)^n`, and `P` is the regularized lower incomplete
gamma. The coefficients satisfy the stable recurrence
`c_n = c_{n−1}·r²·(2n−1)/(2n)`, so the series converges geometrically in `r²`
and never needs the Bessel product form (which would overflow for small `q`).

- `q = 1` reduces to Rayleigh: `1 − e^{−x²/Ω}`.
- `Ω = 0` is the point mass at 0.
- The helper domain is `q ∈ [0.01, 1]`; below `q = 0.01` the series would need
  millions of terms, so the helper returns NaN and the limit is documented.
- Quantiles bisect on `(0, hi]` with doubling expansion.

## Tests added (1 new, total 897)

`Hoyt CDF and quantile helpers match the Nakagami-q law` covers the Rayleigh
reduction, three numerical-integration references for `Hoyt(0.5, 1)`
(`0.25976541`, `0.66297494`, `0.96984347`), `p = 0.1/0.5/0.9` round-trips, the
`Ω = 0` point mass, invalid `q`/`Ω`, f32 support, and sampler-method
delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds a `Hoyt(0.5, 1)` quantile round-trip.
- The long-run continuous block adds 10,000,000-sample empirical CDF gates for
  `Hoyt(0.5, 1)` at `x = 0.5/1/2`. Observed: hoyt(1) `0.663174` vs `0.662975`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 897/897 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further performance work, or newly discovered core gaps.
