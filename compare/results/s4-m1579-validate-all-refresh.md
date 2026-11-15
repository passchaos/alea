# S4-M1579 Validate-All Refresh After S4-M1578

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1905/1905
tests with the discrete quantile inversion gates present:

- native `alea-tests` 939/939,
- WASI Node tests 939/939,
- native and WASI distcheck with the new binomial/negative-binomial/
  geometric/hypergeometric/Zipf/Zeta inversion gates, the Poisson
  huge-lambda inversion gates, the noncentral-t quantile round-trips, the
  binomial walk CDF/mean/variance gate, the HIN 4e6-draw mean gate, the
  tightened 1e9-sample long-run gate, the truncated-normal/uniform gates,
  the noncentral/GPD/SICS gates, hypergeometric variance gates, heavy-tail
  mean gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 960/960 tests (native
939/939). The milestone is gate-only: no library code, stream, or benchmark
changed.
