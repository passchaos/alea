# S4-M1478 Huge-Population Hypergeometric CDF and Quantile

Date: 2026-11-14

## Change

`hypergeometricCdf` and `hypergeometricQuantile` previously returned NaN for
every population above 2^53 and used log-gamma PMF differences for populations
up to 2^53 even when both categories were large. The log-gamma difference
loses precision as `N·log N` grows: at `N = 1e15`, `hypergeometricCdf(0, 1e15,
1e6, 1e6)` returned `2980.957987042` instead of `0.999000500`.

The helpers now:

- fold both categories onto their smaller side through the four hypergeometric
  symmetries (`X ↔ n−X` with `K ↔ N−K`, `X ↔ K−X` with `n ↔ N−n`), so the
  folded view is `Z ~ Hypergeometric(N, min(K, N−K), min(n, N−n))` with
  `X = shift + Z` when both folds or neither apply, and `X = s − Z` (one
  complement) when exactly one fold applies;
- keep the exact tail summation while `N ≤ 1e11` or the smaller folded category
  is at most 20000 (the product-form log-PMF stays accurate for short
  categories);
- use the Poisson limit `Poisson(min(n, N−n)·min(K, N−K)/N)` in the unstable
  region when the expected repeat hits `mean·max(p, r)` are below the normal
  error `O(1/σ)`, and the normal approximation with continuity correction
  otherwise;
- return the closed-form normal quantile
  `ceil(mean + σ·probit(q) − 0.5)` in the normal regime, invert the Poisson
  limit (with the complement tail when folded) in the Poisson regime, and
  bisect over the folded support otherwise; the folded support always fits in
  u64 because it is at most 20000 or the population is at most 1e11;
- treat populations above 2^53 as real-valued instead of returning NaN; the
  integer support is resolved to the nearest representable f64.

No RNG stream changed: the CDF and quantile are deterministic functions and do
not consume engine output, so all benchmark checksums and versioned streams in
`compare/results/reproducibility-matrix.md` are unaffected.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `cdf(5e16, 1e18, 1e17, 5e17)` | NaN | 0.5 | `Φ(0)` |
| `cdf(5e16 + 1.5e8, 1e18, 1e17, 5e17)` | NaN | 0.841344736 | `Φ(1) = 0.841344746` |
| `cdf(5e16 − 1.5e8, 1e18, 1e17, 5e17)` | NaN | 0.158655264 | `Φ(−1) = 0.158655254` |
| `quantile(0.5, 1e18, 1e17, 5e17)` | NaN | 5e16 | mean |
| `quantile(0.975, 1e18, 1e17, 5e17)` | NaN | 5.00000002939946e16 | mean + 1.959964σ |
| `cdf(100, 1e18, 1e10, 1e10)` | NaN | 0.526562199 | `P(Poisson(100) ≤ 100) = 0.5265621985` |
| `quantile(0.5, 1e18, 1e10, 1e10)` | NaN | 100 | Poisson median |
| `cdf(0, 1e15, 1e6, 1e6)` | 2980.957987042 | 0.999000500 | `e^-0.001 = 0.9990004998` |
| `cdf(1, 1e13, 1e6, 1e6)` | 0.994900001 | 0.995321160 | `P(Poisson(0.1) ≤ 1) = 0.99532116` |
| `cdf(1, 1e12, 1e6, 1e6)` | 0.738285000 | 0.735758882 | `2/e = 0.7357588823` |
| `cdf(999999, 1e18, 1e6, 1e18 − 1e10)` | NaN | 0.009950166 | `1 − e^-0.01 = 0.00995016625` |
| `quantile(0.5, 1e18, 1e6, 1e18 − 1e10)` | NaN | 1e6 | folded complement median |
| `cdf(5, 10, 7, 8)` | 21/45 | 21/45 | four-fold exact check |

The `N = 1e11` boundary keeps the exact log-gamma path (error about `2.5e-4`);
`N = 1e12` and above switch to the Poisson limit when valid, which is the more
accurate branch there.

## Empirical Validation

`checkLongRun` now gates the new strategies against the huge-parameter
samplers:

- `hypergeometric(1e18, 1e17, 5e17)` empirical CDF at `mean − 1e8` and
  `mean + 1e8` versus the normal fallback: at 1e6 samples `0.252350` vs
  `0.252492` and `0.747446` vs `0.747508`, at 1e7 samples `0.252459` vs
  `0.252492` and `0.747386` vs `0.747508` (tolerance ±0.002);
- `hypergeometric(1e18, 1e10, 1e10)` empirical CDF at 100 versus the Poisson
  limit: at 1e6 samples `0.526274` vs `0.526562`, at 1e7 samples `0.526723`
  vs `0.526562` (tolerance ±0.002).

A separate 10M-draw probe of the rare-category regime (seed `0x777001`) gives
`mean = 99.994085` and `P(X ≤ 100) = 0.526644` against the Poisson-limit
`0.526562199`, confirming the sampler and the CDF agree beyond the gate
tolerance.

## Validation

- `zig build test --summary all` passes 918/918 (native `alea-tests` 899/899).
- `zig build statcheck` passes.
- `zig build distcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` prints
  `distlongcheck ok (1000000 samples)` with the new huge-population CDF gates.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with the same gates.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
