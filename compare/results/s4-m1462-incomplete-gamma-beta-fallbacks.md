# S4-M1462 Stable Incomplete Gamma and Beta Kernels

Date: 2026-11-14

## Problem

The shared incomplete gamma and beta continued fractions overflow for huge
shape parameters, which silently corrupted many CDF helpers:

| call | before | expected |
| --- | --- | --- |
| `poissonCdf(1e6, 1e6)` | 0.881725 | ~0.5004 |
| `poissonCdf(1e8, 1e8)` | 0.987994 | ~0.5 |
| `poissonCdf(1e12, 1e12)` | 0.999880 | ~0.5 |
| `betaIncomplete(0.5, 1e8, 1e8)` | 0.204612 | 0.5 |
| `betaIncomplete(0.5, 1e9, 1e9)` | -1.177997 | 0.5 |
| `gammaCdf(1e6; 1e6, 1)` | 0.118293 | ~0.5001 |
| `gammaCdf(1e9; 1e9, 1)` | 0.003797 | ~0.5 |
| `negativeBinomialCdf(1e18; 1, 1e-18)` | 0.000000 | 0.632121 |
| `negativeBinomialCdf(1e18; 5, 5e-18)` | 0.000000 | 0.559507 |

## Change

- `gammaIncompleteP`/`gammaIncompleteQ`: Wilson-Hilferty cube-root normal
  approximation for shape `a >= 1e4`; the transform keeps the error `O(1/a)`
  instead of the series/continued-fraction overflow at that scale. `P` uses
  `Φ(z)` and `Q` uses `Φ(−z)` so the upper tail keeps its precision.
- `betaIncomplete`: exact `a = 1` and `b = 1` closed forms; a normal
  approximation with the first Edgeworth correction once `a + b >= 1e7`; the
  exact continued fraction elsewhere.
- `negativeBinomialCdf`: the tiny-p gamma limit
  `P(Gamma(r) ≤ (k+1)·p)` when `r·p <= 1e-6` (error `O(r·p)`).

`poissonCdf`, `gammaCdf`, `chiSquaredCdf`, `erlangCdf`, `maxwellCdf`,
`betaCdf`, `fisherFCdf`, and `studentTCdf` inherit the fixes through the
shared kernels.

## After

`poissonCdf` at `(1e6,1e6)`, `(1e8,1e8)`, and `(1e12,1e12)` measures
`0.500266`, `0.500027`, and `0.5`; `betaIncomplete(0.5; a, a)` is `0.5` up to
`a = 1e9`; `gammaCdf` measures `0.500133` and `0.500004`; the negative
binomial measures `0.632121` and `0.559507`; and the kernel scan matches the
`0.5 − pdf(a)/3` asymptotic at `a = 1e4..1e7`.

## Validation

- New `incomplete gamma and beta stay stable for huge parameters` test.
- `zig build test --summary all` passes 913/913 tests (native `alea-tests`
  894/894), `distcheck`, `statcheck`, and the 10M long run pass, and the full
  16MiB benchmark suite keeps all 457 checksums identical.
