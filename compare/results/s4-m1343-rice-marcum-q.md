# S4-M1343 — Rice CDF/quantile diagnostics via Marcum Q

## Goal

Add CDF and quantile diagnostics for the Rice (Rician) fading distribution:

- `riceCdf(x, nu, sigma) = 1 − Q1(ν/σ, x/σ)`,
- `riceQuantile(p, nu, sigma)` via deterministic bisection,
- matching `cdf` / `quantile` methods on `Rice`.

## Implementation

### Marcum Q1

`marcumQ1(a, b)` evaluates

`Q1(a, b) = e^{−a²/2} Σ_{k≥0} (a²/2)^k/k! · Q(k+1, b²/2)`

with each term formed in log space (`log c_k + log Q(k+1, y) − a²/2`) so the
exponential prefactor cannot overflow. Terms are positive and bounded by
`Q1 ≤ 1`; the loop stops once it is past the Poisson-like peak and the current
term is below `64·ε` of the sum. The per-term `gammaIncompleteQ` keeps the
evaluation stable when `y` is large enough that a forward recurrence would
start from an underflowed `e^{−y}`.

### Rice CDF and quantile

- `sigma = 0` is the point mass at `ν`; `ν = 0` reduces exactly to the
  Rayleigh closed form `1 − e^{−x²/(2σ²)}`.
- For `ν/σ > 200` the Marcum series is replaced by a Gaussian tail
  approximation using the exact Rice mean and variance, documented as the
  large-noncentrality strategy.
- Quantiles bisect on `(0, hi]` with doubling expansion; `p = 0 → 0`,
  `p = 1 → +∞`.

## Tests added (1 new, total 896)

`Rice CDF and quantile helpers match Marcum Q values` covers the Rayleigh
reduction and closed-form quantiles, three numerical-integration references for
`Rice(1,1)` (`0.07347260`, `0.26712020`, `0.73098794`), `p = 0.1/0.5/0.9`
round-trips, the `sigma = 0` point mass, invalid parameters, f32 support, and
sampler-method delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds a `Rice(1,1)` quantile round-trip.
- The long-run continuous block adds 10,000,000-sample empirical CDF gates for
  `Rice(1, 0.5)` at `x = 0.5/1/2`. Observed: rice(1) `0.396518` vs the exact
  `1 − Q1(2,2) = 0.39650` (identity `Q1(a,a) = ½ + ½e^{−a²}I0(a²)`).
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 896/896 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
Hoyt diagnostics, further performance work, or newly discovered core gaps.
