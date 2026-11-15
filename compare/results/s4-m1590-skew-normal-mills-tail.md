# S4-M1590 Skew-Normal Far-Left Tail (Mills Expansion)

Date: 2026-11-15

## Problem

The S4-M1574 audit left the skew-normal far-left tail unresolved:
`skewNormalCdf` computes `Φ(z) − 2T(z, α)`, and Owen's T adaptive Simpson has
an absolute quadrature floor around `1e-8`. For `z = −5, α = 1` the true
`F = Φ(−5)² = 8.2169e-14`, but the helper returned `4.5352e-10` (5500x too
large); at `z = −6` the same floor would return ~`4.5e-10` against
`9.7336e-19` (about `4.6e8` times too large). The lower-tail quantiles below
`p ≈ 1e-9` were therefore not meaningful.

## Derivation

For `z = −a < 0` and `s = α > 0`:

```
F(−a; s) = 2 ∫_a^∞ φ(u) Φ(−s u) du.
```

The Mills ratio `Φ(−s u) = φ(s u) M(s u)` with
`M(y) ~ 1/y − 1/y³ + 3/y⁵ − 15/y⁷ + …` gives

```
F = (1/π) Σ_{k≥0} (−1)^k (2k−1)!! s^{−2k−1} J_k,
J_k = ∫_a^∞ e^{−βu²} u^{−2k−1} du,   β = (1+s²)/2,
J_0 = ½ E1(βa²),   J_k = (e^{−βa²}a^{−2k} − 2βJ_{k−1})/(2k).
```

`J_0` uses the `E1` asymptotic series `e^{−x} Σ (−1)^m m!/x^{m+1}` truncated
at its smallest term.

## Change

Added `skewNormalLowerTailAsym(a, s)` (eight series terms) and dispatch in
`skewNormalCdfImpl`:

```
z < 0 and shape > 0 and shape·(−z) >= 3.5  ->  Mills expansion
otherwise                                  ->  Φ(z) − 2T(z, α)
```

The switch preserves monotonicity: the direct branch is inflated by its
quadrature floor, so the CDF still increases through the switch. `scale = 0`,
infinities, NaN, `shape ≤ 0`, and `z ≥ 0` keep their previous behavior.

## Accuracy

Against the exact `α = 1` closed form `F(z; 1) = Φ(z)²`:

| `z` | Exact `Φ(z)²` | New | Relative error |
| --- | --- | --- | --- |
| −5 | `8.216912366e-14` | `8.216946e-14` | `4.1e-6` |
| −6 | `9.733551813e-19` | `9.733554e-19` | `1.9e-7` |
| −7 | `1.637920147e-24` | `1.637920e-24` | `1.3e-8` |

Independent Simpson references over `s ∈ {0.5, 0.75, 1, 1.5, 2, 3, 4}`:

- `s·a = 3.5` (switch): worst relative error `2.5e-2`
- `s·a = 4.0`: `3.7e-3`
- `s·a = 4.5`: `4.0e-4`
- `s·a = 5.0`: `4.1e-5`
- `s·a ≥ 6`: below `5e-7`

Quantiles at `p ∈ {1e-9, 1e-12, 1e-15, 1e-18}` round-trip through the new
CDF within `5e-4` relative.

## Validation

- New test `skew-normal far-left tail uses the Mills expansion` pins the
  `α = 1` exact values, monotonicity in `shape`, the `z = −400` underflow,
  and the tail quantile round-trips.
- `zig build test distcheck --summary all` passes 964/964 tests (native
  943/943), including the existing skew-normal reference values and the
  distcheck `skew-normal(0)=0.250011` gate.
- CDF/quantile-only change: no sampling stream, API, or benchmark changed.

## Remaining Limit

Below the `shape·|z| = 3.5` switch the direct `Φ − 2T` form still has its
`~1e-8` absolute quadrature floor, so relative accuracy degrades for CDF
values below `~1e-7` that fall outside the asymptotic branch (for example
`z` just above the switch with a large shape). The severe far tail that the
S4-M1574 audit flagged is resolved.
