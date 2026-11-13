# S4-M1272 — Static matrix normal distribution

## Goal

Add the comptime-dimension matrix normal distribution
`StaticMatrixNormal(T, rows, cols)` over rows×cols matrices:

```
f(X) ∝ exp(-½·tr(V⁻¹ (X−M)ᵀ U⁻¹ (X−M))),
```

storing the mean and both Cholesky factors inline. This mirrors the existing
`StaticMultivariateNormal(T, dimension)` allocation-free workflow and completes
the matrix normal family alongside the allocator-backed `MatrixNormal(T)`.

## Implementation

### Public API

`StaticMatrixNormal(T, rows, cols)` (comptime rows, cols ≥ 1):

- Type aliases: `Matrix = [rows][cols]T`, `RowCovariance = [rows][rows]T`,
  `ColCovariance = [cols][cols]T`
- `init(mean: Matrix, row_covariance: RowCovariance, col_covariance: ColCovariance) MatrixNormalError!Self`
  / `new(...) Self`
- `rowsValue`, `colsValue`
- `meanValue`, `meanAt(row, col)`
- `expectedValue`, `modeValue`
- `rowCovarianceAt(row, col)`, `colCovarianceAt(row, col)`, `varianceAt(row, col)`
- `sample(rng) Matrix`, `sampleFrom(source) Matrix`
- `sampleInto(rng, *Matrix)`, `sampleIntoFrom(source, *Matrix)`
- `sampleManyInto(rng, []Matrix)`, `sampleManyIntoFrom(source, []Matrix)`

`multi.StaticMatrixNormal(T, rows, cols)` re-exports the type.

### Validation and sampling

- Mean entries must be finite; both covariances are factored with the existing
  `factorMultivariateCovariance` helper, which validates finite symmetric
  positive-semidefinite input and supports rank-deficient factors.
- Zero mean buffers of length `rows`/`cols` are stack arrays, so construction
  performs no allocation.
- Sampling uses the same in-place transform as `MatrixNormal(T)`:
  1. Fill the matrix row-major with iid standard normals.
  2. Left-multiply by lower-triangular `L_U` bottom-up per column.
  3. Right-multiply by `L_Vᵀ` right-to-left per row.
  4. Add the mean.

Because the static and dynamic samplers use identical draw order and arithmetic
order, they produce bit-for-bit identical samples for the same engine seed; the
test suite asserts this directly.

## Tests added (3 new, total 804)

1. `StaticMatrixNormal constructor validates parameters` — NaN mean and
   non-PSD row covariance.
2. `StaticMatrixNormal matches the dynamic matrix normal` — 32 bit-for-bit
   comparisons across a 2×3 matrix with non-identity row/column covariances.
3. `StaticMatrixNormal sampling, caller buffers, and batches work` — accessors,
   caller-owned `sampleInto`, three-sample batch, 5,000-sample identity
   covariance moments, and f32 support.

## Validation

- `zig build test` passes: 804/804 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "StaticMatrixNormal"` passes
  3/3.
- `docs/api-reference.md` updated for all 22 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1272 row added.

## Deviations and notes

- The static variant uses nested arrays (`[rows][cols]T`) instead of the flat
  row-major slices used by the dynamic variant; batch fills therefore take
  `[]Matrix` rather than a flat slice.
- `expectedValue` and `modeValue` return the stored mean by value; the matrix is
  small and comptime-sized, so this avoids pointer lifetime questions.
- No allocator or `deinit` is required, matching the other static multivariate
  samplers.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
