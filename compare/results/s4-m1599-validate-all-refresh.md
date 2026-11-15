# S4-M1599 Validate-All Refresh After S4-M1598

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1917/1917
tests with the von Mises CDF distcheck gate present:

- native `alea-tests` 945/945,
- WASI Node tests 945/945,
- native and WASI distcheck with the new 40k-sample von Mises sampler/CDF
  gate (6-SE tolerance), the six-family discrete inversion gates, the
  Poisson huge-lambda inversion gates, the noncentral-t quantile round-trips,
  the binomial walk CDF/mean/variance gate, the HIN 4e6-draw mean gate, the
  tightened 1e9-sample long-run gate, the truncated-normal/uniform gates, the
  noncentral/GPD/SICS gates, hypergeometric variance gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 966/966 tests
(native 945/945). Tooling-only milestone: no library code, sampling stream,
public API, or benchmark changed.
