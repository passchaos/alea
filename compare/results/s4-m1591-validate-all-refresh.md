# S4-M1591 Validate-All Refresh After S4-M1590

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1913/1913
tests with the skew-normal Mills tail present:

- native `alea-tests` 943/943,
- WASI Node tests 943/943,
- native and WASI distcheck with the skew-normal CDF reference values and
  `skew-normal(0)=0.250011` gate, the six-family discrete inversion gates,
  the Poisson huge-lambda inversion gates, the noncentral-t quantile
  round-trips, the binomial walk CDF/mean/variance gate, the HIN 4e6-draw
  mean gate, the tightened 1e9-sample long-run gate, the
  truncated-normal/uniform gates, the noncentral/GPD/SICS gates,
  hypergeometric variance gates, heavy-tail mean gates, Wishart gates, and
  long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 964/964 tests
(native 943/943). The milestone is CDF/quantile-only: no sampling stream,
public API, or benchmark changed.
