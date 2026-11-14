# S4-M1549 Validate-All Refresh After S4-M1548

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1897/1897
tests with the noncentral-t CDF/quantile diagnostics present:

- native `alea-tests` 935/935,
- WASI Node tests 935/935,
- native and WASI distcheck with the noncentral-t quantile round-trips plus
  the truncated-normal/uniform gates, noncentral/GPD/SICS gates,
  hypergeometric variance gates, Poisson quantile gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 954/954 tests (native
935/935). Sampling streams are unchanged; the new helpers are deterministic
diagnostics.
