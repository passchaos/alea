# S4-M1506 Validate-All Refresh After S4-M1505

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1849/1849
tests with the matrix-normal scale gates present:

- native `alea-tests` 911/911,
- WASI Node tests 911/911,
- distcheck (including the new static `diag(4,9)` and dynamic 1×1
  variance-4 matrix-normal gates), distcheck-libc, statcheck, and
  profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 930/930 tests (native
911/911), and `zig build statcheck`/`distcheck` pass. The matrix-normal and
matrix-t stream change remains the intended versioned correction recorded in
the reproducibility matrix.
