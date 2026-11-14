# S4-M1537 Validate-All Refresh After S4-M1536

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1875/1875
tests with the 3x3 Wishart covariance regression present:

- native `alea-tests` 924/924,
- WASI Node tests 924/924,
- native and WASI distcheck with the hypergeometric variance gates, the
  Poisson quantile gates, the heavy-tail mean gates, the Wishart gates, and
  the long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 943/943 tests (native
924/924). No library code or RNG stream changed in this milestone.
