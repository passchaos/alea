# S4-M1494 Von Mises Huge-Kappa Rejection Stall

Date: 2026-11-14

## Change

The circular `VonMises` sampler uses the Best–Fisher (1979) rejection
constants

```
disc = √(1 + 4κ²)
rho  = 2κτ / ((disc + 1)(τ + √(2τ)))
r    = (1 + rho²) / (2·rho)
```

For `κ ≳ 4.5e15`, `rho` rounds to exactly 1, so `r = 1`, `f = 1`, `c = 0`,
and both acceptance tests are permanently false — the rejection loop never
terminates. For `κ > 6.7e153`, `disc` overflows to inf and `r` becomes NaN,
which previously fell into the tiny-κ uniform fallback and returned a uniform
angle instead of the concentrated point mass.

The scalar sampler now detects `r == 1` or `NaN r` and samples the
concentrated limit `N(mu, 1/κ)`, which matches the von Mises law to f64
precision once `1/κ` is below the density's `O(1/κ)` error (κ ≥ 4.5e15 gives
`3.4/κ ≈ 7e-16`). The tiny-κ uniform fallback remains for `r` infinite or
non-positive-finite. The SIMD kernel applies the same per-lane limit and
retires those lanes before the rejection loop.

The vMF family already had a `κ > 1e12` point-mass shortcut
(`vonMisesFisherPointWithWoodFrom` and the vector/matrix variants), so only
the circular sampler needed the fix.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `VonMises(0, 1e16).sample` | infinite loop | \|x\| ≤ 2.2e-8 | `N(0, 1e-16)` |
| `VonMises(0, 1e300).sample` | uniform angle in (−π, π] | \|x\| ≤ 1e-150 | `N(0, 1e-300)` |
| `fillVonMises` at κ = 1e16 | infinite loop | \|x\| ≤ 2.2e-8 | `N(0, 1e-16)` |
| vector `vonMisesFrom` at κ = 1e16 | infinite loop | \|x\| ≤ 2.2e-8 | `N(0, 1e-16)` |

Moderate-κ draws take the original Best–Fisher loop unchanged, so their
streams are unaffected.

## Validation

- `zig build test --summary all` passes 926/926 (native `alea-tests` 907/907).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
