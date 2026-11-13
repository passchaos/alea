# S4-M1339 — Advanced continuous CDF and quantile diagnostics

## Goal

Extend the continuous diagnostics surface to four advanced families that
previously had only moments and sampling:

- `betaPrimeCdf` / `betaPrimeQuantile`,
- `logLogisticCdf` / `logLogisticQuantile`,
- `inverseGammaCdf` / `inverseGammaQuantile`,
- `nakagamiCdf` / `nakagamiQuantile`,
- matching `cdf` / `quantile` methods on `BetaPrime`, `LogLogistic`,
  `InverseGamma`, and `Nakagami`.

`BetaPrime` already had methods from S4-M1285; they now delegate to the new
free helpers so the two surfaces share one implementation.

## Implementation

- Beta-prime: `I_{x/(1+x)}(α, β)` via `betaIncomplete`; quantile maps
  `u = BetaQuantile(p)` to `u/(1−u)`.
- Log-logistic: `1/(1 + (x/scale)^{-shape})`; quantile is
  `scale·(p/(1−p))^{1/shape}`. `scale = 0` and `shape = +∞` are point masses at
  0 and `scale`.
- Inverse-gamma: `Q(α, β/x)` via `gammaIncompleteQ`; quantile inverts through
  `1/gammaQuantile(1−p, α, 1/β)`.
- Nakagami-m: `P(m, m·x²/Ω)` via `gammaIncompleteP`; quantile is
  `√gammaQuantile(p, m, Ω/m)`, so `m = 1` reproduces Rayleigh and `m = 0.5`
  reproduces half-normal. `Ω = 0` is the point mass at 0.

## Tests added (1 new, total 893)

`advanced continuous CDF and quantile helpers match known values` covers the
exact `BetaPrime(2,5)` CDF(1) `= 0.890625`, `LogLogistic(2,3)` at
`x = 2/4`, `InverseGamma(3,2)` at `x = 2` (`Q(3,1) = 2.5e^{−1}`),
`Nakagami(1,2)` Rayleigh reduction, quantile round-trips at
`p = 0.1/0.5/0.9`, degenerate `scale = 0`/`shape = +∞`/`Ω = 0` cases, invalid
parameters, f32 support, and sampler-method delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds four quantile round-trips.
- The long-run continuous block adds 10,000,000-sample empirical CDF gates for
  `LogLogistic(1.5, 2.5)` at `x = 0.75/1.5/3` and `Nakagami(2, 3)` at
  `x = 1/2/3`. Observed: log-logistic(1.5) `0.499597` vs `0.500000`,
  nakagami(2) `0.745229` vs `0.745227`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 893/893 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
SkewNormal/PERT/inverse-Gaussian/ExGaussian diagnostics (Owen's T and
bisection-based quantiles), or newly discovered core gaps.
