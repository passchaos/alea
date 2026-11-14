# S4-M1488 ExGaussian CDF Exponent and Tiny-Shape Quantile Resolution

Date: 2026-11-14

## Change

Three numerical issues remained in the continuous diagnostics:

- `exGaussianCdf` computed `σ²/(2τ²)` directly, which overflows for
  `σ = τ = 1e300` and left the exponential correction term at zero; the CDF
  then reduced to `Φ(z)` and the quantile bisection returned a value 28
  orders of magnitude too small. The exponent now uses `0.5·(σ/τ)²`.
- `gammaQuantile` bisects linearly over `[0, hi]` for 100 iterations, so its
  resolution floor is `hi·2^-100 ≈ 1e-30`; quantiles for shapes below about
  `1e-2` were pinned to that floor (`gammaQuantile(0.5, 1e-3, 1)` returned
  `3.9e-31` instead of `5.2e-302`). When the bisection leaves `lo = 0`, the
  lower tail is now refined with a 100-iteration log-space bisection over
  `[log(floatMin), log(hi)]`.
- `betaQuantile` has the same linear floor (about `1e-14` because of its
  `64·eps` early exit) and now uses the same log-space refinement;
  `betaQuantile(0.5, 1e-3, 1)` returns `0.5^1000 = 9.33e-302` instead of
  `7.1e-15`.

No RNG stream changed: these are deterministic CDF/quantile helpers.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `exGaussianCdf(0, 0, 1e300, 1e300)` | 0.5 | 0.238421692 | `Φ(0) − e^{0.5}·Φ(−1)` |
| `exGaussianCdf(-1e300, 0, 1e300, 1e300)` | 0.158655264 | 0.056696556 | `Φ(−1) − e^{1.5}·Φ(−2)` |
| `exGaussianQuantile(0.5, 0, 1e300, 1e300)` | −4.46e271 | 8.757981e299 | bisection of the corrected CDF |
| `gammaQuantile(0.5, 1e-3, 1)` | 3.944305e-31 | 5.244206e-302 | `(0.5·Γ(1.001))^{1000}` |
| `gammaQuantile(0.5, 1e-6, 1)` | 3.944305e-31 | 2.225074e-308 | underflow floor |
| `betaQuantile(0.5, 1e-3, 1)` | 7.105427e-15 | 9.332636e-302 | `0.5^{1000}` |

The refined quantiles round-trip through `gammaCdf`/`betaIncomplete` at
`1e-12`, and the moderate-parameter `ExGaussian`, `gammaQuantile`, and
`betaQuantile` tests pass unchanged.

## Validation

- `zig build test --summary all` passes 923/923 (native `alea-tests` 904/904).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
