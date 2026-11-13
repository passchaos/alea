# S4-M1315 — SIMD Bingham sampling

## Goal

Add a per-lane SIMD Bingham sampler on S², completing the SIMD directional
family alongside `VectorVonMisesFisher` and `VectorWatson`.

## Implementation

`VectorBingham(VectorType)` wraps the scalar `Bingham(T, 3)` sampler (which
owns the Jacobi eigendecomposition, ACG precision, envelope, and fast-path
flags) and samples `[3]VectorType` with one independent sample per lane:

- isotropic matrices delegate to `vectorUnitSphereFrom`,
- the high-concentration point-mass fast path uses a per-lane fair coin
  between `±mode_axis`,
- otherwise each lane draws a Gaussian ACG proposal scaled by the shared
  precisions, normalizes it, evaluates the Bingham log-ratio per lane, and
  retires accepted lanes,
- accepted proposals are rotated by the shared eigenvector matrix and written
  into the result.

Accessors: `matrixValue`, `eigenvaluesValue`, `spectralGapValue`, `modeAxis`.
Free functions: `vectorBingham`, `vectorBinghamFrom`, `vectorBinghamChecked`,
`vectorBinghamCheckedFrom`, `fillVectorBingham`, `fillVectorBinghamFrom`,
`fillVectorBinghamChecked`, `fillVectorBinghamCheckedFrom`.

## Tests added (2 new, total 873)

1. **f64x4 axial moment** — `diag(0, −3, −3)` with 40,000 lane samples;
   `E[x0²]` matches the direct numerical integral
   `∫ w² exp(3w²) dw / ∫ exp(3w²) dw` within `±0.01`, and
   `E[x1²] = (1 − E[x0²])/2` within `±0.01`; every lane is a unit vector.
2. **f32x8, fills, and errors** — bulk fills produce unit lanes, a checked
   single sample works, and a NaN matrix returns `InvalidParameter`.

## Validation

- Focused `VectorBingham` tests pass 2/2.
- `zig build apicheck` and `zig build distcheck` pass.
- `zig build test --summary all` passes 873/873 tests with all documentation
  gates.
- `docs/api-reference.md` updated for all 19 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1315 row added.

## Next bar

Vector Bingham docs/distcheck/benchmark integration, SIMD Kent sampling, or
newly discovered core gaps.
