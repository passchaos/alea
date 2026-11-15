# S4-M1567 Validate-All Refresh After S4-M1566

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1903/1903
tests with the noncentral-t monotonicity grid present:

- native `alea-tests` 938/938,
- WASI Node tests 938/938,
- native and WASI distcheck with the noncentral-t quantile round-trips, the
  binomial walk CDF/mean/variance gate, the HIN 4e6-draw mean gate, the
  tightened 1e9-sample long-run gate, the truncated-normal/uniform gates,
  the noncentral/GPD/SICS gates, hypergeometric variance gates, Poisson
  quantile gates, heavy-tail mean gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 959/959 tests (native
938/938). The milestone is test-only: no production code, stream, or
benchmark changed.
