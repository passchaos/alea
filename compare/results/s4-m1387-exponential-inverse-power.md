# S4-M1387 — Exponential-kernel inverse-power and extreme-value samplers

## Goal

Replace the `−log(U)` transform in the Rayleigh, Weibull, Pareto, Fréchet,
Gumbel, and generalized Pareto samplers with the standard exponential kernel,
whose law is identical, and route the sampler facade methods through the shared
free functions instead of their hand-inlined formulas.

## Implementation

For `U ~ Uniform(0, 1]`, `E = −log(U)` is `Exp(1)`. Each sampler therefore has
an exact exponential form:

- Rayleigh: `scale · √(−2·log U)` → `scale · √(2E)`.
- Weibull: `scale · (−log U)^{1/shape}` → `scale · E^{1/shape}`.
- Pareto: `scale · U^{−1/shape}` → `scale · exp(E/shape)`.
- Fréchet: `location + scale · (−log U)^{−1/shape}` →
  `location + scale · E^{−1/shape}`.
- Gumbel: `location − scale · log(−log U)` → `location − scale · log E`.
- Generalized Pareto: `μ + σ·(U^{−ξ} − 1)/ξ` → `μ + σ·(exp(ξE) − 1)/ξ`
  (and `μ + σE` for `ξ = 0`).

`rayleighFrom`, `weibullFrom`, `paretoFrom`, `frechetFrom`, `gumbelFrom`, and
`generalizedParetoPointFrom` use `Rng.standardExponentialFastFrom` (the
ziggurat kernel) for `E`. The `Rayleigh`, `Pareto`, `Weibull`, and `Fréchet`
facade `sample` methods previously repeated the log/pow formulas (including
`std.math.pow`); they now call the shared free functions, matching the
`sampleFrom` paths. The vectorized bulk fills keep their current uniform-log
transforms and checksums.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea rayleigh` | 258.7M samples/s | 1007.6M samples/s | +289% |
| `alea pareto` | 166.0M samples/s | 408.2M samples/s | +146% |
| `alea gumbel` | 88.7M samples/s | 187.3M samples/s | +111% |
| `alea gumbel direct` | 97.5M samples/s | 210.1M samples/s | +115% |
| `alea weibull` | 52.9M samples/s | 81.5M samples/s | +54% |
| `alea frechet` | 53.4M samples/s | 81.4M samples/s | +52% |
| `alea fillRayleigh` / `fillWeibull` / `fillGumbel` | — | unchanged | bulk fills keep the uniform-log transforms |

The sampled laws are unchanged, but the consumed random stream differs, so the
checksums shift and are stable: `rayleigh` `328614.711` → `328553.185`,
`pareto` `392416.900` → `393674.511`, `weibull` `236938.497` → `236542.767`,
`frechet` `177964.774` → `177234.872`, `gumbel` `75437.389` → `75920.302`,
and `gumbel direct` `75081.027` → `76881.435`.

## Validation

- All Rayleigh, Pareto, Weibull, Fréchet, Gumbel, and generalized Pareto
  tests pass.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, further inverse-CDF transform tuning, or newly
discovered core gaps.
