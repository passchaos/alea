# S4-M1532 Normal CDF Lower-Tail Resolution

Date: 2026-11-15

## Problem

`normCdf` computed `0.5·(1 + erf(x/√2))`. For negative `x` the
Abramowitz-Stegun erf returns `-(1 - P(t)e^{-x²/2})`, so the sum cancels:
once `P(t)e^{-x²/2}` drops below half an ulp of 1, the result flushes to
zero. `normCdf(-8.5)` returned exactly 0 even though `Φ(-8.5) ≈ 9.5e-18`.

This broke lower-tail quantiles that route through the normal
approximation. `gammaQuantile(1e-300, 1e6, 1)` returned `991647.3` whose CDF
is 0 instead of the correct `963404.3`; the bisection stopped at the point
where the fallback CDF first became zero.

## Change

`erfAbramowitzStegun` now uses a shared `erfComplementTerm(ax) = 1 − erf(ax)`
helper, and `normCdf` uses the complement form directly for negative `x`:

```
Φ(x) = 0.5 · erfComplementTerm(-x/√2)      for x < 0
```

The same branch is applied to the f32 and SIMD-lane paths. The upper tail
(`x ≥ 0`) keeps the existing form, and the mid-range values are unchanged to
rounding.

Resolved tail values:

| x | before | after | reference |
| --- | --- | --- | --- |
| -8.5 | 0 | 9.597e-18 | 9.48e-18 |
| -12 | 0 | 1.832e-33 | 1.78e-33 |
| -20 | 0 | 2.97e-89 | 2.8e-89 |
| -38 | 0 | 3.36e-316 (subnormal) | 4.9e-316 |
| -39 | 0 | 0 (below subnormal) | 3.4e-333 |

`gammaQuantile` now round-trips through the tail:

| q | quantile | CDF(quantile) | relative error |
| --- | --- | --- | --- |
| 1e-300 | 963404.298 | 9.999999999875e-301 | -1.3e-11 |
| 1e-100 | 978872.851 | 1.000000000005e-100 | +4.6e-12 |
| 1e-20 | 990764.213 | 9.999999999981e-21 | -1.9e-12 |

This also improves the gamma/chi-squared, binomial, and negative-binomial
normal-approximation CDFs in their extreme tails. Copula sampling clamps the
uniform to `(ε/2, 1−ε/2)`, so its output mapping is unchanged.

## Validation

- New tests `normCdf resolves the lower tail below 1e-16` and
  `gammaQuantile resolves the lower tail for large shapes`.
- `zig build test --summary all` passes 942/942 (native `alea-tests`
  923/923).
- `zig build distcheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
