# S4-M1639 Validate-All Refresh After S4-M1638

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the vector binomial pmf-binned long gate in the long-run path:

- native `alea-tests` 950/950,
- WASI Node tests 950/950,
- native and WASI distcheck (the default mode compiles the `checkLongRun`
  path containing `checkVectorBinomialBins`; the 1e9 execution evidence is
  S4-M1638), the continuous/tail/copula gates, the GEV and von Mises
  sampler/CDF gates, the scalar and vector binned chi-square gates, the
  discrete inversion, Poisson huge-lambda, noncentral-t, binomial walk, HIN,
  tightened 1e9 long-run, truncated-normal/uniform, noncentral/GPD/SICS,
  hypergeometric variance, heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 971/971 (native
950/950). Tooling-only: no library code, sampling stream, or benchmark
changed.
