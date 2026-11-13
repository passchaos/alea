# S4-M1307 — Matrix Fisher distribution on SO(3)

## Goal

Close the square `p = k = 3` case that the S4-M1305 Gibbs sampler rejects.
The matrix Fisher distribution on SO(3) has density

```
f(R) ∝ exp(tr(FᵀR)),   R ∈ SO(3),
```

and is the standard rotation distribution in attitude estimation and
directional statistics.

## Key reduction

Parameterize a rotation by a unit quaternion `q = (w, x, y, z)`. Expanding
`tr(FᵀR(q))` gives

```
tr(FᵀR(q)) = tr(F) + qᵀAq
```

with the symmetric 4×4 matrix

```
A = [ 0,             f32−f23,       f13−f31,       f21−f12
      f32−f23,  −2(f22+f33),       f12+f21,       f13+f31
      f13−f31,       f12+f21,  −2(f11+f33),       f23+f32
      f21−f12,       f13+f31,       f23+f32,  −2(f11+f22) ].
```

Since `q` lives on S³, sampling reduces **exactly** to a Bingham distribution
on S³, which Alea already provides. The sampled quaternion is converted back
to a rotation matrix. The result is an exact, independent SO(3) sampler — no
burn-in or thinning.

## Implementation

### Public API

`MatrixFisher(T)`:

- `init(parameter)` validates finite entries and builds the Bingham sampler
  once; `new` is the debug-only panicking constructor.
- `parameterValue`, `parameterAt`, `quaternionParameterValue` (the derived
  4×4 matrix).
- `sample` / `sampleFrom`, `fill` / `fillFrom`.

Free functions: `matrixFisher`, `matrixFisherFrom`, `matrixFisherChecked`,
`matrixFisherCheckedFrom`, `fillMatrixFisher`, `fillMatrixFisherFrom`,
`fillMatrixFisherChecked`, `fillMatrixFisherCheckedFrom`.

`multi.MatrixFisher(T)` re-exports the type, and `MatrixFisherError` reports
invalid parameters.

## Tests added (4 new, total 862)

1. **Quadratic-form identity** — for four quaternions (including non-axis
   cases), `qᵀAq + tr(F) = tr(FᵀR(q))` within `1e-10`. This directly validates
   the parameter reduction.
2. **Zero parameter is uniform on SO(3)** — 20,000 samples have zero entry
   means within `±0.02`, orthonormal rows/columns, and determinant `+1`.
3. **Isotropic parameter** `F = 2I` — the exact `E[tr(R)]` from the S³
   Bingham marginal `p(w) ∝ exp(4d·w²)√(1−w²)` matches the 20,000-sample mean
   within `±0.02`.
4. **Free functions, fill, and f32** — bulk fills are orthonormal and invalid
   parameters return `InvalidParameter`.

## Validation

- `zig test src/root.zig --test-filter "MatrixFisher"` passes 4/4.
- `zig build test --summary all` passes 862/862 tests; `apicheck` and all
  documentation gates are green.
- `docs/api-reference.md` updated for all 22 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1307 row added.

## Next bar

Matrix Fisher docs/distcheck/benchmark integration, vector/SIMD directional
sampling, further long-run goodness-of-fit checks, or newly discovered core
gaps against local Rust `rand` / `rand_distr` evidence.
