# S4-M1505 Matrix-Normal Scale Gates in Distcheck

Date: 2026-11-15

## Change

`distcheck` now gates the matrix-normal Cholesky diagonal through non-unit
covariance scales, which the previous correlation-only gate could not detect:

- `StaticMatrixNormal(f64, 2, 1)` with row covariance `diag(4, 9)` and unit
  column covariance must sample empirical variances near 4 and 9
  (`[3.7, 4.3]` and `[8.4, 9.6]` at 20,000 samples);
- the allocator-backed `MatrixNormal(f64)` 1×1 with row variance 4 must sample
  an empirical variance near 4 over the same 20,000 samples.

Before S4-M1503 both gates would have measured about 1.0, so they guard the
diagonal multiply against future regressions. The WASI branch uses
`std.heap.wasm_allocator`, matching the other allocator-backed distcheck
blocks.

## Validation

- `zig build distcheck` passes with the new gates.
- `zig build test --summary all` passes 930/930 (native `alea-tests` 911/911).
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
