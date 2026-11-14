# S4-M1482 Fading and Noncentral Extreme-Parameter Moments

Date: 2026-11-14

## Change

The fading and noncentral moment helpers computed large products directly or
subtracted two huge `lgamma` values, so extreme parameters returned NaN, inf,
or silently wrong values. This milestone makes them overflow-safe:

- `Rice`: `kFactor` uses `(ν/σ)²/2`; the mean computes `t = (ν/(2σ))²` and
  switches to the deep-Rician limit (`mean = ν`, `variance = σ²`) once
  `ν/σ > 1e150`, where the `exp(-t)·I₀(t)·(1+2t)` form would overflow; the
  variance uses `2σ² − (E/σ − ν/σ)(E/σ + ν/σ)`, which keeps the `E[X]²`
  cancellation stable.
- `Hoyt`: `expectedValue` now uses the Gaussian-circular identity
  `E[X] = σ·√(2/π)·E(√(1−q²))` with the complete elliptic integral of the
  second kind evaluated by the arithmetic-geometric mean. The previous
  Bessel-based form overestimated the mean for `q < 1` (for `q = 0.5`,
  `Ω = 2` it returned 1.4369 against the 1.2219 Monte Carlo/elliptic value,
  which made the variance negative). `varianceValue` stays `Ω − E[X]²` and is
  now non-negative.
- `Nakagami`: `expectedValue` uses the large-shape asymptotic
  `Γ(m+1/2)/Γ(m) ≈ √m·(1 − 1/(8m) + 1/(128m²))` above `m = 1e7` and
  `ratio·√Ω/√m` to avoid `Ω/m` overflow; `varianceValue` uses the
  `Ω·(1/(4m) − 1/(32m²))` asymptotic above `m = 1e7` because the
  `1 − ratio²/m` difference loses the `O(1/m)` term.
- `NoncentralT`: the scale factor uses the asymptotic
  `c = 1 + 3/(4ν) + 25/(32ν²)` above `ν = 1e8`, and the variance uses
  `μ²·(1/(2ν) + 15/(8ν²)) + ν/(ν−2)`, which preserves the `O(1/ν)` term that
  a rounded `scale − c²` difference loses.
- `NoncentralF`: the mean uses `1 + λ/d1`; the variance splits the
  `(1+λ/d1)²` product into `d1/(d2−4) + 2λ/(d2−4) + (λ/(d2−4))·(λ/d1)` and
  keeps the `(d2/(d2−2))²` factor separate, so huge `d1, d2, λ` stay finite.
- `ScaledInverseChiSquared`: the mean uses `scale2·df/(df−2)` and the variance
  `2·(df/(df−2))²·(scale2/(df−4))·scale2`, avoiding the `df·scale2` and
  `scale2²` products.

No RNG stream changed: these are deterministic moment helpers.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `Hoyt(0.5, 2).expectedValue()` | 1.436951 | 1.222262 | Monte Carlo 1.2219, elliptic 1.2224 |
| `Hoyt(0.5, 2).varianceValue()` | −0.064828 | 0.506076 | `2 − mean²` |
| `Hoyt(1e-300, 1e300).expectedValue()` | inf | 7.978846e149 | `√Ω·√(2/π)` |
| `Hoyt(1e-300, 1e300).varianceValue()` | −inf | 3.633802e299 | `Ω·(1 − 2/π)` |
| `Rice(1e300, 1).expectedValue()` | NaN | 1e300 | ν |
| `Rice(1e300, 1).varianceValue()` | NaN | 1 | σ² |
| `Rice(1e300, 1e300).expectedValue()` | NaN | 1.548572e300 | Bessel form at t = 0.25 |
| `Rice(1e300, 1e300).kFactor()` | NaN | 0.5 | `(ν/σ)²/2` |
| `Nakagami(1e300, 1e300).expectedValue()` | 1 | 1e150 | √Ω |
| `Nakagami(1e300, 1e300).varianceValue()` | 1e300 | 0.25 | `Ω/(4m)` |
| `Nakagami(1e300, 1).expectedValue()` | 1e-150 | 1 | √Ω |
| `Nakagami(1e300, 1).varianceValue()` | 1 | 2.5e-301 | `Ω/(4m)` |
| `NoncentralT(1e300, 1e300).expectedValue()` | inf | 1e300 | μ |
| `NoncentralT(1e300, 1e300).varianceValue()` | NaN | 5e299 | `1 + μ²/(2ν)` |
| `NoncentralF(1e300, 1e300, 1e300).varianceValue()` | NaN | 14 | standard formula |
| `ScaledInverseChiSquared(1e300, 1e300).expectedValue()` | inf | 1e300 | scale² |
| `ScaledInverseChiSquared(1e300, 1e300).varianceValue()` | NaN | 2e300 | `2·scale⁴/(df−4)` |

Moderate-parameter regression checks confirm the scaled forms reproduce the
direct formulas: `Rice(2, 1)` mean/variance, `Nakagami(2, 3)`,
`NoncentralT(10, 1)`, `NoncentralF(5, 10, 1)`, and
`ScaledInverseChiSquared(10, 2)` match the pre-change values; `Hoyt(0.5, 2)`
matches the independent Monte Carlo/elliptic reference instead of the old
negative-variance value.

## Validation

- `zig build test --summary all` passes 920/920 (native `alea-tests` 901/901).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
