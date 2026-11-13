# S4-M1273 — Copula and matrix-normal adoption examples

## Goal

Add executable, cataloged examples for the newly added copula and matrix-normal
families so users can adopt them without reading tests:

- `examples/copulas.zig` — static and allocator-backed Gaussian and Student-t
  copulas, probit-transformed correlation recovery, tail dependence, caller-owned
  buffers, batches, and clone support.
- `examples/matrix_normal.zig` — dynamic and allocation-free static matrix
  normal sampling, row/column covariance diagnostics, caller-owned buffers, and
  batch outputs.

## Implementation

### Examples

`examples/copulas.zig`:

1. Builds a static 2D Gaussian copula with `ρ = 0.7` and prints one sample.
2. Recovers the input correlation from 5,000 samples by applying
   `alea.distributions.probit` to each uniform coordinate and computing the
   empirical Pearson correlation.
3. Builds a dynamic 3D `GaussianCopula(f64)`, samples into a caller-owned
   buffer, and prints a two-sample batch.
4. Builds a static Student-t copula with `ν = 3`, `ρ = 0.8`, and prints the
   joint lower-tail rate over 10,000 samples, demonstrating tail dependence.
5. Builds and clones a dynamic `StudentTCopula(f64)` with `ν = 5` and prints a
   sample plus the degrees-of-freedom accessor.

`examples/matrix_normal.zig`:

1. Builds a dynamic 2×3 `MatrixNormal(f64)` with non-identity row and column
   covariances.
2. Prints shape, mean, row covariance `(0,1)`, column covariance `(0,2)`, and
   variance `(0,0)` diagnostics.
3. Samples through the allocation-returning, caller-owned, and batch APIs.
4. Builds a static 2×2 `StaticMatrixNormal(f64, 2, 2)`, prints a sample, a
   two-sample batch, and the `varianceAt(1,1)` diagnostic.

Both examples print deterministic values for their fixed seeds and end with a
short guidance line.

### Build and catalog integration

- `build.zig`: new `run-copulas` and `run-matrix-normal` steps, both wired into
  the aggregate `zig build examples` step.
- `tools/examplecheck.zig`: both examples added to the checked example list with
  source tokens that lock the demonstrated APIs.
- `tools/toolingcheck.zig`: both new build steps added to the tooling catalog.
- `docs/examples.md`: two new catalog rows.
- `docs/tooling.md`: two new build-step rows.

## Validation

- `zig build run-copulas` prints:
  - `gaussian copula empirical correlation: 0.698`
  - `student-t copula joint lower-tail rate: 0.062`
- `zig build run-matrix-normal` prints the expected 2×3 shape and covariance
  diagnostics (`row covariance(0,1): 0.300`, `col covariance(0,2): 0.100`,
  `variance(0,0): 1.000`).
- `zig build examples` runs all examples, including the two new ones.
- `zig build test` passes: 804/804 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- `compare/results/core-rand-coverage.md` S4-M1273 row added.

## Deviations and notes

- The examples intentionally use small sample counts (5,000 / 10,000) so the
  aggregate examples gate stays fast; the statistical unit tests carry the
  larger-sample checks.
- No new library symbols were added, so `docs/api-reference.md` is unchanged.
- The examples rely on the existing public `probit` helper rather than adding a
  new inverse-CDF API just for the demonstration.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
