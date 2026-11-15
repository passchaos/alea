# S4-M1659 Validate-All Refresh After S4-M1658

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the two fair clz long-run mean gates in the long-run path:

- native `alea-tests` 950/950,
- WASI Node tests 950/950,
- native and WASI distcheck (the default mode compiles the `checkLongRun`
  path containing the `geometric(0.5)` and `negativeBinomial(5,0.5)` mean
  gates; the 1e9 execution evidence is S4-M1658), the continuous/tail/copula
  gates, the GEV and von Mises sampler/CDF gates, the scalar/vector binned
  chi-square gates including the fair/dyadic binomial and geometric pmf
  gates, the discrete inversion, Poisson huge-lambda, noncentral-t, binomial
  walk, HIN, tightened 1e9 long-run, truncated-normal/uniform,
  noncentral/GPD/SICS, hypergeometric variance, heavy-tail mean, Wishart, and
  long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 971/971 (native
950/950). Tooling-only: no library code, sampling stream, or benchmark
changed.
