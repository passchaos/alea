# S4-M1539 Validate-All Refresh After S4-M1538

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1877/1877
tests with the 3D MatrixT/InverseWishart regression present:

- native `alea-tests` 925/925,
- WASI Node tests 925/925,
- native and WASI distcheck with the hypergeometric variance gates, the
  Poisson quantile gates, the heavy-tail mean gates, the Wishart gates, and
  the long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 944/944 tests (native
925/925). No library code or RNG stream changed in this milestone.
