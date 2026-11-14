# S4-M1545 Validate-All Refresh After S4-M1544

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1889/1889
tests with the noncentral CDF/quantile diagnostics present:

- native `alea-tests` 931/931,
- WASI Node tests 931/931,
- native and WASI distcheck with the noncentral chi-squared and noncentral F
  quantile round-trips plus the GPD/SICS gates, hypergeometric variance
  gates, Poisson quantile gates, heavy-tail mean gates, Wishart gates, and
  long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 950/950 tests (native
931/931). Sampling streams are unchanged; the new helpers are deterministic
diagnostics.
