# S4-M1627 Validate-All Refresh After S4-M1626

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the six vector binned chi-square gates in the long-run path:

- native `alea-tests` 950/950,
- WASI Node tests 950/950,
- native and WASI distcheck (the default mode compiles the `checkLongRun`
  path containing `checkBinnedChiSquareVector`; the 1e9 execution evidence is
  S4-M1626), the continuous/tail/copula gates, the GEV and von Mises
  sampler/CDF gates, the six-family discrete inversion gates, the Poisson
  huge-lambda inversion gates, the noncentral-t quantile round-trips, the
  binomial walk CDF/mean/variance gate, the HIN 4e6-draw mean gate, the
  tightened 1e9-sample long-run gate, the truncated-normal/uniform gates, the
  noncentral/GPD/SICS gates, hypergeometric variance gates, heavy-tail mean
  gates, Wishart gates, and long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 971/971 (native
950/950). Tooling-only: no library code, sampling stream, or benchmark
changed.
