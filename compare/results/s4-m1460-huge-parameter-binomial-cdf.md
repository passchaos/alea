# S4-M1460 Stable Huge-Parameter Binomial CDF and Quantile

Date: 2026-11-14

## Problem

`binomialCdf` used `betaIncomplete(1 - p, n - k, k + 1)`, which loses
precision for tiny `p` and huge `n`:

| call | before | expected |
| --- | --- | --- |
| `binomialCdf(0; 1e18, 1e-18)` | 1.000000 | 0.367879 |
| `binomialCdf(5; 1e18, 5e-18)` | 1.000000 | 0.615961 |
| `binomialCdf(100; 1e18, 1e-16)` | -inf | 0.526562 |
| `binomialCdf(5e8; 1e9, 0.5)` | -0.564876 | ~0.5 |
| `binomialCdf(3e17; 1e18, 0.3)` | 1.000000 | ~0.5 |

The incomplete beta cannot represent `1 - p` when `p` rounds it to one, and
its continued fraction loses accuracy once the shape parameters reach the
hundreds of millions.

## Change

- Fold `p > 0.5` onto the lower tail:
  `P(X ≤ k) = 1 − P(Bin(n, 1−p) ≤ n−k−1)`.
- Tiny `p` (`n·p² ≤ 1e-6`): Poisson limit with mean `n·p`; the error is
  `O(n·p²) ≤ 1e-6`.
- Large variance (`n·p·(1−p) ≥ 1e7`): normal approximation with continuity
  correction; the error is `O(1/√(n·p·(1−p))) ≈ 1.6e-4` at the boundary.
- Everything else keeps the exact incomplete-beta path.

`binomialQuantile` inherits the fallbacks through its bisection.

## After

- `binomialCdf(0; 1e18, 1e-18) = 0.367879`,
  `binomialCdf(5; 1e18, 5e-18) = 0.615961`,
  `binomialCdf(100; 1e18, 1e-16) = 0.526562`,
  `binomialCdf(20; 1e18, 2e-17) = 0.559093`.
- `binomialCdf(5e8; 1e9, 0.5) = 0.500013`,
  `binomialCdf(3e17; 1e18, 0.3) = 0.5`, and the far tails return 0/1.
- The symmetry is exact: `binomialCdf(8; 20, 0.7)` equals
  `1 − binomialCdf(11; 20, 0.3)`.
- `binomialQuantile(0.5; 20, 0.3) = 6` (unchanged),
  `binomialQuantile(0.5; 1e18, 1e-18) = 1`,
  `binomialQuantile(0.5; 1e9, 0.5) = 5e8`, and
  `binomialQuantile(0.5; 1e18, 0.3) = 3e17`.

## Validation

- New `binomial CDF fallbacks stay stable for huge parameters` test covers
  the Poisson, normal, symmetry, and quantile paths. The 1e18-trial quantile
  assertions are 64-bit-only because the bisection indexes `usize`; 32-bit
  targets return NaN there by design, and the core guide documents the cap.
- `zig build test --summary all` passes 912/912 tests (native `alea-tests`
  893/893), `distcheck`, `statcheck`, and the 10M long run pass, and the full
  16MiB benchmark suite keeps all 457 checksums identical.
