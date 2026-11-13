# S4-M1267 — Bingham distribution on Sⁿ⁻¹

## Goal

Add a Bingham distribution on the (n−1)-sphere for comptime dimension n ≥ 2:

```
f(x | A) ∝ exp(xᵀ A x),   x ∈ Sⁿ⁻¹,   A symmetric.
```

The Bingham is the canonical directional model for undirected axes with
anisotropic concentration. It generalizes the axial Watson distribution
(`A = κ μμᵀ`) to a full symmetric matrix, and is absent from local Rust
`rand` / `rand_distr` core.

## Implementation

### Public API

`Bingham(T, n)` (comptime n ≥ 2):

- `init(matrix: [n][n]T) BinghamError!Self` / `new(matrix) Self`
- `matrixValue(self) [n][n]T` — symmetrized matrix parameter
- `eigenvaluesValue(self) [n]T` — eigenvalues sorted descending
- `spectralGapValue(self) T` — λ₁ − λ₂
- `modeAxis(self) [n]T` — sign-canonicalized eigenvector of λ₁
- `dimensionValue(self) usize`
- `sample(self, rng) [n]T`, `sampleFrom(self, source) [n]T`
- `fill(self, rng, dest) void`, `fillFrom(self, source, dest) void`

Free-function family:

- `bingham`, `binghamFrom`, `binghamChecked`, `binghamCheckedFrom`
- `fillBingham`, `fillBinghamFrom`, `fillBinghamChecked`, `fillBinghamCheckedFrom`

`BinghamError` aliases `error.InvalidParameter` for non-finite matrix entries
or non-finite spectral spreads.

### Sampling algorithm

Exact rejection sampling using the angular central Gaussian (ACG) method of
Kent, Ganeiber & Mardia (2013):

1. Symmetrize the input matrix as `(A + Aᵀ)/2`; the antisymmetric part does not
   affect the density on the sphere.
2. Compute a deterministic symmetric Jacobi eigendecomposition
   `A = V Λ Vᵀ` with λ₁ ≥ … ≥ λₙ. Jacobi is allocation-free, uses 64 sweeps
   with a machine-epsilon-scaled convergence tolerance, and sorts eigenvalues
   (and eigenvector columns) descending.
3. Work in the eigenbasis with `B = λ₁ I − Λ ≥ 0`, so the target is
   proportional to `exp(−yᵀ B y)`.
4. Propose `y` from an ACG distribution with precision `P = I + 2B/ν`: draw
   `w ~ N(0, I)`, set `zᵢ = wᵢ/√Pᵢ`, and normalize `y = z/‖z‖`.
5. Accept with probability `exp(−t)(1 + 2t/ν)^{n/2} / C(ν)`, where
   `t = yᵀ B y` and `C(ν)` is the envelope maximum (computed in log space).
6. Rotate `x = V y` back to the original frame.

The ACG precision parameter ν is chosen at construction time from a
deterministic scan of candidates `1, 2, 4, …, 2n` plus `n − 1`. The score is
the proposal's exact mean `t` compared with the envelope maximum; this avoids
both the high-dimensional one-direction acceptance collapse (where `ν ≈ n − 1`
is optimal) and the isotropic-transverse collapse (where `ν = 1` is optimal).

Fast paths:

- Isotropic matrices (`λ₁ = … = λₙ`) delegate to `unitSphereSurfaceFrom`, which
  is the exact uniform distribution on the sphere.
- When `λ₁ − λ₂ > 1e12`, the distribution is numerically a point mass at
  `±modeAxis`; one fair coin flip selects the sign. This mirrors the existing
  Watson/vMF high-concentration fast paths and avoids unbounded rejection in
  extreme-concentration regimes.

The sampler is exact for any positive ν, so the adaptive ν choice only affects
throughput, not correctness. The stream shape is deterministic for a given
engine and matrix.

## Tests added (15 new, total 772)

1. `Bingham constructor validates matrices and symmetrizes` — NaN/Inf rejection,
   antisymmetric-part removal, degenerate top eigenvalue and zero spectral gap.
2. `Bingham Jacobi eigendecomposition matches analytic spectrum` — known
   eigenvalues `[5, 3, 1]` and orthonormal eigenvector columns.
3. `Bingham isotropic matrix is uniform on the sphere` — unit norms and
   `E[xᵢ²] ≈ 1/3`.
4. `Bingham 3D concentrated samples are unit vectors around the dominant axis` —
   `A = diag(0, −10, −10)`.
5. `Bingham 3D girdle samples concentrate near the equatorial subspace` —
   `A = diag(−10, 0, 0)`.
6. `Bingham rotated dominant axis concentrates around the expected eigenvector` —
   dominant axis `e₂` and `modeAxis` accessor.
7. `Bingham 2D axial concentration` — S¹ bipolar case.
8. `Bingham high concentration degenerates to the dominant axis` — point-mass
   fast path at gap `1e13`.
9. `Bingham free functions and fill work` — fill, checked, and invalid-matrix
   error paths.
10. `Bingham direct-source sampling matches facade and is reproducible` — same
    seed produces identical facade/direct streams.
11. `Bingham 3D moment matches numerical integration` — `E[x₁²]` compared with
    the exact `∫w² exp(kw²) dw / ∫exp(kw²) dw` to within 0.01 over 20,000
    samples.
12. `Bingham rotated matrix matches diagonal moment` — non-diagonal
    `A = Q diag(0, −3, −3) Qᵀ`; eigenvector and moment checks.
13. `Bingham high-dimensional anisotropic matrices remain samplable` — n = 8
    isotropic-transverse and single-direction cases exercise the adaptive ν.
14. `Bingham f32 sampling works`.
15. The Jacobi/eigenvector rotation is exercised by the rotated-axis and
    rotated-matrix tests above.

## Validation

- `zig build test` passes: 772/772 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- `zig build validate` passes all native gates (examples, statcheck, distcheck,
  distcheck-libc, profilecheck, and PractRand self-test) in about 5m55s.
- `docs/api-reference.md` updated for all 21 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1267 row added.
- Focused `zig test src/root.zig --test-filter Bingham` passes 15/15.

## Deviations and notes

- The input matrix is symmetrized rather than rejected for asymmetry: the
  Bingham density only depends on `xᵀAx`, and `xᵀAx = xᵀ((A+Aᵀ)/2)x` on the
  sphere, so this is the mathematically faithful interpretation.
- The high-concentration point-mass threshold is an explicit numerical
  approximation, documented in the same spirit as Watson's `κ > 1e12` and vMF's
  `κ > 1e12` fast paths.
- Scalar and fill APIs are provided; vector/SIMD Bingham sampling remains a
  possible follow-up because rejection loops and per-lane eigendecomposition do
  not fit the existing vector-sampler shape without a separate design.
- No `expectedValue` accessor is provided because the Bingham is antipodally
  symmetric and `E[x] = 0` identically; `modeAxis` and `spectralGapValue`
  expose the meaningful concentration diagnostics instead.

## Next bar

Matrix von Mises-Fisher, Kent distribution, copula methods, vector/SIMD
Bingham sampling, longer statistical validation runs, or newly discovered core
gaps against local Rust `rand` / `rand_distr` evidence.
