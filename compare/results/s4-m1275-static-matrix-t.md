# S4-M1275 — Static matrix-variate Student-t distribution

## Goal

Add the comptime-dimension matrix-variate Student-t
`StaticMatrixT(T, rows, cols)` over rows×cols matrices:

```
X = M + L_U Z L_Vᵀ,   X /= √(s/ν),   s ~ χ²(ν),
```

storing a `StaticMatrixNormal(T, rows, cols)` inline. This completes the
matrix-t family alongside the allocator-backed `MatrixT(T)` and mirrors the
allocation-free `StaticMatrixNormal` workflow.

## Implementation

### Public API

`StaticMatrixT(T, rows, cols)` (comptime rows, cols ≥ 1):

- Type aliases: `Matrix = [rows][cols]T`, `RowCovariance = [rows][rows]T`,
  `ColCovariance = [cols][cols]T`
- `init(mean, row_covariance, col_covariance, degrees_of_freedom) MatrixTError!Self`
  / `new(...) Self`
- `rowsValue`, `colsValue`, `degreesOfFreedomValue`, `dfValue`
- `meanValue`, `meanAt(row, col)`, `expectedValue`, `modeValue`
- `rowCovarianceAt`, `colCovarianceAt`
- `varianceAt(row, col) MatrixTError!?T` — `U[row,row]·V[col,col]·ν/(ν−2)` for
  `ν > 2`, `null` for `ν ≤ 2`
- `sample(rng) Matrix`, `sampleFrom(source) Matrix`
- `sampleInto(rng, *Matrix)`, `sampleIntoFrom(source, *Matrix)`
- `sampleManyInto(rng, []Matrix)`, `sampleManyIntoFrom(source, []Matrix)`

`multi.StaticMatrixT(T, rows, cols)` re-exports the type.

### Validation and sampling

- Degrees of freedom must be positive and finite.
- Mean/covariance validation and PSD factoring are delegated to
  `StaticMatrixNormal(T, rows, cols)`, so rank-deficient factors are supported
  and construction remains allocation-free.
- Sampling draws a static matrix normal into the output matrix, then draws one
  shared `χ²(ν)` scale through `chiSquaredFrom` and divides every entry in
  place.
- The static and dynamic matrix-t samplers use identical draw and arithmetic
  order, so they produce bit-for-bit identical samples for the same engine
  seed; the test suite asserts this directly.

## Tests added (3 new, total 813)

1. `StaticMatrixT constructor validates parameters` — df `0`, NaN, and
   non-PSD row covariance.
2. `StaticMatrixT matches the dynamic matrix-t` — 32 bit-for-bit comparisons
   across a 2×3 matrix with non-identity row/column covariances and `df = 5`.
3. `StaticMatrixT sampling, variance, batches, and f32 work` — df/variance
   accessors (`5/3` for `df = 5`, `null` for `df = 2`), caller-owned
   `sampleInto`, three-sample batch, covariance diagnostics, and f32 support.

## Validation

- `zig build test` passes: 813/813 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "StaticMatrixT"` passes 3/3.
- `docs/api-reference.md` updated for all 24 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1275 row added.

## Deviations and notes

- The static variant uses nested arrays (`[rows][cols]T`) and `[]Matrix` batch
  slices, matching `StaticMatrixNormal` rather than the flat slices of the
  dynamic variant.
- `expectedValue` and `modeValue` return the stored location matrix by value;
  the matrix is comptime-sized and small.
- No allocator or `deinit` is required.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
