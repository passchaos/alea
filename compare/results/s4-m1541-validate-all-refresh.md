# S4-M1541 Validate-All Refresh After S4-M1540

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1879/1879
tests with the static 3D matrix-variate regression present:

- native `alea-tests` 926/926,
- WASI Node tests 926/926,
- native and WASI distcheck with the hypergeometric variance gates, the
  Poisson quantile gates, the heavy-tail mean gates, the Wishart gates, and
  the long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 945/945 tests (native
926/926). No library code or RNG stream changed in this milestone.
