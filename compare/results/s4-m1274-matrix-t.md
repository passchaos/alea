# S4-M1274 — Matrix-variate Student-t distribution

## Goal

Add the matrix-variate Student-t distribution `MT(M, U, V, ν)` over rows×cols
matrices:

```
X = M + L_U Z L_Vᵀ,   X /= √(s/ν),   s ~ χ²(ν),
```

where `U = L_U L_Uᵀ`, `V = L_V L_Vᵀ`, and `Z` is filled with iid standard
normals. The shared chi-squared scale gives heavier joint tails than the matrix
normal and makes `MatrixT` the natural matrix-variate companion to the
Student-t copula and the univariate `StudentT`. It is absent from local Rust
`rand` / `rand_distr` core.

## Implementation

### Public API

`MatrixT(T)`:

- `init(allocator, mean, row_covariance, col_covariance, degrees_of_freedom) !Self`
  / `new(...) !Self`
- `deinit(*Self)`, `clone(self, allocator) !Self`
- `rowsValue`, `colsValue`, `degreesOfFreedomValue`, `dfValue`
- `meanValues`, `meanAt(row, col)`
- `expectedValue(allocator) ![]T` (location/mean parameter), `modeValue(allocator) ![]T`
- `rowCovarianceAt(row, col)`, `colCovarianceAt(row, col)`
- `varianceAt(row, col) Error!?T` — `U[row,row]·V[col,col]·ν/(ν−2)` for
  `ν > 2`, `null` for `ν ≤ 2`
- `sample(allocator, rng) ![]T`, `sampleFrom(allocator, source) ![]T`
- `sampleInto(rng, out)`, `sampleIntoFrom(source, out)` (zero-alloc)
- `sampleIntoChecked` / `sampleIntoCheckedFrom`
- `sampleManyInto` / `sampleManyIntoFrom` (zero-alloc batch)

`multi.MatrixT(T)` re-exports the type, and `MatrixTError` aliases the
distribution `Error` set.

### Construction and sampling

- Degrees of freedom must be positive and finite.
- The mean and both covariances are validated and factored by the existing
  `MatrixNormal(T)` constructor, including PSD/rank-deficient support.
- `sampleInto` first draws a matrix normal into the output buffer, then draws
  one shared `χ²(ν)` scale through `chiSquaredFrom` and divides every entry in
  place. No scratch allocation is required after construction.
- Batch helpers loop over the single-sample path so repeated-sample stream
  shape is preserved exactly.
- A 1×1 `MatrixT` is exactly a univariate Student-t, which the heavy-tail test
  exercises directly.

## Tests added (6 new, total 810)

1. `MatrixT constructor validates parameters` — df `0`, negative, NaN, and
   non-PSD row covariance.
2. `MatrixT mean and variance match the Student-t formulas` — `df = 5`
   variance `5/3` from the accessor and 20,000-sample second moment; `df = 2`
   returns `null` variance.
3. `MatrixT heavy tails exceed the normal distribution` — 1×1 `df = 3` case;
   the `|X| > 5` rate is far above the normal baseline.
4. `MatrixT large degrees of freedom approaches the matrix normal` — `df = 1e7`
   second moment is within 0.08 of 1.
5. `MatrixT matches manual matrix-normal plus chi-squared composition` —
   bit-for-bit comparison against `MatrixNormal` + `chiSquaredFrom` for the same
   engine stream.
6. `MatrixT clone, caller buffers, batches, and f32 work` — clone, checked
   output lengths, batch fills, allocating samples, mean export, and f32
   support.

## Validation

- `zig build test` passes: 810/810 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "MatrixT"` passes 6/6.
- `docs/api-reference.md` updated for all 26 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1274 row added.

## Deviations and notes

- `expectedValue` returns the location/mean parameter for all ν; it is the
  actual mean only for ν > 1, matching the usual matrix-t convention.
- `varianceAt` returns `null` for ν ≤ 2 rather than infinity, following the
  existing `Wishart`/`InverseWishart` optional-moment style.
- Only the allocator-backed runtime-dimension variant is provided; a static
  `StaticMatrixT(T, rows, cols)` can follow the `StaticMatrixNormal` pattern if
  allocation-free comptime shapes are needed.

## Next bar

Matrix von Mises-Fisher, Kent distribution, static matrix-t, vector/SIMD
copula/Bingham sampling, longer statistical validation runs, or newly
discovered core gaps against local Rust `rand` / `rand_distr` evidence.
