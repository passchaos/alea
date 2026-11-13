# S4-M1313 — SIMD Watson sampling and Watson moment fix

## Goal

Add a per-lane SIMD Watson sampler on S² and, while validating it against the
scalar moment accessor, fix a latent bug in the scalar Watson axial moment.

## SIMD Watson

`VectorWatson(VectorType)` samples `[3]VectorType` with one independent Watson
sample per lane and a shared axis/concentration:

- For `n = 3` the uniform-sphere Beta proposal is `Beta(1, 1)`, so each lane
  proposes `w = 2U − 1` and accepts against `exp(κ(w² − 1))` (bipolar) or
  `exp(κw²)` (girdle), retiring accepted lanes.
- The tangent angle is drawn uniformly per lane; the e₁-frame point is
  Householder-reflected to the shared axis.
- `κ = 0` delegates to `vectorUnitSphereFrom`, `κ > 1e12` returns a per-lane
  fair coin between `±axis`, and `κ < −1e12` samples the equator uniformly.
- The Householder reflection is factored into `vectorHouseholderReflect`,
  shared with the SIMD vMF sampler.

Free functions: `vectorWatson`, `vectorWatsonFrom`, `vectorWatsonChecked`,
`vectorWatsonCheckedFrom`, `fillVectorWatson`, `fillVectorWatsonFrom`,
`fillVectorWatsonChecked`, `fillVectorWatsonCheckedFrom`.

## Latent scalar Watson moment bug

`Watson.meanCosineSquared()` used the Kummer ratio

```
M(3/2, (n+1)/2, κ) / (n · M(1/2, (n−1)/2, κ))
```

which is wrong. The correct ratio from
`∫ w²(1−w²)^{(n−3)/2} e^{κw²} dw` is

```
M(3/2, (n+2)/2, κ) / (n · M(1/2, n/2, κ)).
```

For `n = 3, κ = 5` the old code returned `0.588`, while the exact value is
`0.764266…`; the new SIMD sampler matched the exact value, exposing the bug.
Additional fixes:

- the moderate-|κ| series now uses 160 terms (60 terms had ~7% truncation
  error at `κ = 50`),
- the girdle asymptotic is `1/(−2κ)` for all `n` (the old `(n−1)/(−2κ)` was
  wrong by a factor of `n−1`),
- the bipolar asymptotic includes the second-order `−(n−1)/(4κ²)` correction.

## Tests added (4 new, total 871)

1. `VectorWatson` bipolar (`κ = 5`) and girdle (`κ = −5`) mean `z²` match the
   corrected scalar `meanCosineSquared()` within `±0.02`.
2. `VectorWatson` `κ = 0` uniformity (`E[z²] ≈ 1/3`) and f32x8 unit norms.
3. `VectorWatson` free functions, fills, and checked error paths.
4. `Watson mean cosine squared matches direct integration` locks the corrected
   accessor at `κ = 5` (`0.764266…`), `κ = −5` (`0.098297…`), uniform 3D
   (`1/3`), and uniform 4D (`1/4`).

## Validation

- Focused `VectorWatson` tests pass 4/4 and all 13 `Watson` tests pass.
- `zig build apicheck` and `zig build distcheck` pass.
- `zig build test --summary all` passes 871/871 tests with all documentation
  gates.
- `docs/api-reference.md` updated for all 17 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1313 row added.

## Next bar

Vector Watson docs/distcheck/benchmark integration, SIMD Kent/Bingham sampling,
or newly discovered core gaps.
