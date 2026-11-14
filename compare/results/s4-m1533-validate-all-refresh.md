# S4-M1533 Validate-All Refresh After S4-M1532

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1873/1873
tests with the resolved normal lower tail present:

- native `alea-tests` 923/923,
- WASI Node tests 923/923,
- native and WASI distcheck with the hypergeometric variance gates, the
  Poisson quantile gates, the heavy-tail mean gates, the Wishart gates, and
  the long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 942/942 tests (native
923/923). The change affects only deterministic CDF/quantile diagnostics in
the extreme lower tail; sampling streams are unchanged.
