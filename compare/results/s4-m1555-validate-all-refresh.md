# S4-M1555 Validate-All Refresh After S4-M1554

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1897/1897
tests with the noncentral-t large-dof quadrature fix present:

- native `alea-tests` 935/935,
- WASI Node tests 935/935,
- native and WASI distcheck with the noncentral-t quantile round-trips plus
  the HIN 4e6-draw mean gate, the tightened 1e9-sample long-run gate, the
  truncated-normal/uniform gates, the noncentral/GPD/SICS gates,
  hypergeometric variance gates, Poisson quantile gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 956/956 tests (native
935/935). Sampling streams are unchanged; the fix only affects the
deterministic noncentral-t CDF/quantile diagnostics.
