# S4-M1593 Validate-All Refresh After S4-M1592

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1915/1915
tests with the wrapped Cauchy CDF/quantile present:

- native `alea-tests` 944/944,
- WASI Node tests 944/944,
- native and WASI `alea-tests` include the new wrapped Cauchy CDF/quantile
  test; native and WASI distcheck run the existing discrete/continuous/tail/
  copula gates, the six-family discrete inversion gates, the Poisson
  huge-lambda inversion gates, the noncentral-t quantile round-trips, the
  binomial walk CDF/mean/variance gate, the HIN 4e6-draw mean gate, the
  tightened 1e9-sample long-run gate, the truncated-normal/uniform gates, the
  noncentral/GPD/SICS gates, hypergeometric variance gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 965/965 tests
(native 944/944). The milestone is diagnostics-only: no sampling stream,
benchmark, or existing API behavior changed.
