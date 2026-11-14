# S4-M1504 Validate-All Refresh After S4-M1503

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1849/1849
tests with the matrix-normal Cholesky diagonal fix present:

- native `alea-tests` 911/911,
- WASI Node tests 911/911,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 930/930 tests (native
911/911), `zig build statcheck` and `zig build distcheck` pass. The
matrix-normal and matrix-t stream change is the intended versioned
distribution correction recorded in the reproducibility matrix.
