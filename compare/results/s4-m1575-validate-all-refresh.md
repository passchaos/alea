# S4-M1575 Validate-All Refresh After S4-M1574

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1905/1905
tests with the tiny-tail CDF fixes present:

- native `alea-tests` 939/939,
- WASI Node tests 939/939,
- native and WASI distcheck with the noncentral-t quantile round-trips, the
  binomial walk CDF/mean/variance gate, the HIN 4e6-draw mean gate, the
  tightened 1e9-sample long-run gate, the truncated-normal/uniform gates,
  the noncentral/GPD/SICS gates, hypergeometric variance gates, Poisson
  quantile gates, heavy-tail mean gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 958/958 tests (native
939/939). Sampling streams are unchanged; the fixes only affect the
deterministic half-normal, truncated-normal, and Kumaraswamy CDF/quantile
diagnostics.
