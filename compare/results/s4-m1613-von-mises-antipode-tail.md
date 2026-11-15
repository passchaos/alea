# S4-M1613 Von Mises Antipode Tail Series

Date: 2026-11-15

## Problem

The von Mises CDF uses the Fourier–Bessel series for `κ <= 1e4`, whose
`~1e-15` absolute cancellation floor limits the relative accuracy of the
lower tail near the `μ − π` antipode. For `κ = 5`, `cdf(quantile(1e-12))`
was off by `~3.1e-5`.

## Change

Added a local density-integral series for `δ = d + π` below
`min(1e-3, 0.1/√κ)`:

```
f(−π+s) ≈ e^{−2κ}·e^{κs²/2} / (2π·I₀e(κ))
F(−π+δ) ≈ e^{−2κ}/(2π·I₀e(κ)) · δ·[1 + κδ²/6 + κ²δ⁴/40 + κ³δ⁶/336 + κ⁴δ⁸/3456]
```

with `I₀e(κ) = exp(logBesselI0(κ) − κ)`. The threshold keeps `κδ² <= 0.01`,
so the five-term series truncation is below `~1e-14` relative.

## Results (`cdf(quantile(p))` relative error, μ = 0)

| κ | p=1e-9 before | after | p=1e-12 before | after | p=1e-15 before | after |
| --- | --- | --- | --- | --- | --- | --- |
| 5 | — | `1.3e-11` | `3.1e-5` | `5.8e-9` | `7.9e-3` | `1.4e-5` |
| 10 | — | `4.8e-8` | — | `7.0e-13` | — | `7.0e-10` |
| 50 | — | `2.7e-8` | — | `3.3e-5` | — | `5.5e-2` |

The `κ = 5` p=1e-12 case improves by nearly four orders. The remaining
`κ = 5` p=1e-15 error is the f64 angle representation near `−π`
(`eps·π/δ ≈ 3.5e-5`); the `κ = 50` p=1e-12 case is in the bulk-angle region
(not near the antipode), where the Fourier series keeps its `~3e-5` floor.

## Validation

- `zig build test distcheck --summary all` passes 971/971 tests (native
  950/950), including the von Mises CDF/quantile references and the
  monotonicity grid (the local branch only triggers within `1e-3` of the
  antipode).
- CDF-only change: no sampling stream, public API, or benchmark changed.
