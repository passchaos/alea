# S4-M1340 — ExGaussian and inverse-Gaussian CDF/quantile diagnostics

## Goal

Add CDF and quantile diagnostics for two advanced continuous families:

- `exGaussianCdf` / `exGaussianQuantile` for `X = N(μ, σ²) + Exp(mean τ)`,
- `inverseGaussianCdf` / `inverseGaussianQuantile` for
  `X ~ IG(mean μ, shape λ)`,
- matching `cdf` / `quantile` methods on `ExGaussian` and `InverseGaussian`.

## Implementation

- `normLogCdf` computes `log Φ(x)` with the asymptotic tail expansion
  `Φ(−w) ≈ φ(w)/w·(1 − 1/w² + 3/w⁴ − 15/w⁶ + 105/w⁸ − 945/w¹⁰ + 10395/w¹²)`
  for `w > 10`, so the helpers avoid the `exp(large)·Φ(very negative)` NaN.
- ExGaussian: `Φ(z) − exp(σ²/(2τ²) − (x−μ)/τ)·Φ(z − σ/τ)` with
  `z = (x−μ)/σ`; `σ = 0` reduces to the shifted exponential
  `1 − e^{−(x−μ)/τ}`. Quantiles use deterministic bisection on a
  `μ ± 40·std` bracket with expansion.
- Inverse-Gaussian:
  `Φ(z₁) + exp(2λ/μ)·Φ(z₂)` with `z₁ = √(λ/x)(x/μ − 1)` and
  `z₂ = −√(λ/x)(x/μ + 1)`; the second term is evaluated as
  `exp(2λ/μ + log Φ(z₂))`. `mean = 0` and `shape = +∞` are point masses at
  0 and `mean`. Quantiles bisect on `(0, hi]` with doubling expansion.

## Tests added (1 new, total 894)

`ExGaussian and InverseGaussian CDF and quantile helpers` covers the shifted
exponential limit, a 400,000-step numerical convolution reference
(`0.46044048` for `ExGaussian(1, 0.5, 1.5).cdf(2)`), three `IG(1,2)` reference
values (`0.23235719`, `0.62769784`, `0.91504668`), `p = 0.1/0.5/0.9`
round-trips, `p = 0/1` endpoints, zero-mean/infinite-shape point masses,
invalid parameters, f32 support, and sampler-method delegation.

## Distcheck and long-run gates

- `checkConstructorErgonomics` adds both quantile round-trips
  (`1e-4` for ExGaussian, `1e-6` for inverse-Gaussian).
- The long-run continuous block adds 10,000,000-sample empirical CDF gates for
  `ExGaussian(1, 0.5, 1.5)` at `x = 1/2/3` and `InverseGaussian(1, 2)` at
  `x = 0.5/1/2`. Observed: ex-gaussian(2) `0.460507` vs `0.460440`,
  inverse-gaussian(1) `0.627772` vs `0.627698`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Validation

- `zig build test` passes 894/894 with all doc gates.
- `zig build distcheck` passes; `zig build wasi-report` ends
  `profilelongcheck ok`.
- `zig fmt --check` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
SkewNormal/PERT diagnostics (Owen's T / Beta mapping), Rice/Hoyt (Marcum Q), or
newly discovered core gaps.
