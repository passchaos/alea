# S4-M1706 Validate-All Refresh After S4-M1705

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1929/1929
tests with the five dyadic vector binomial probability gates present:

- native `alea-tests` 951/951,
- WASI Node tests 950/950,
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the six dyadic vector geometric pmf gates and the five dyadic
  vector binomial gates (`p = 0.0625`, `0.125`, `0.25`, `0.375`, `0.75`), the
  fair/non-dyadic binomial gates, the large/extreme vector binomial CDF
  gates, the `fillBinomial(1000, 0.012)` CDF gates, the Zipf and vector Zipf
  CDF gates, the vector hypergeometric and `fillHypergeometric(100, 30, 10)`
  CDF gates, the negative-binomial CDF/mean gates, the zeta and vector zeta
  CDF gates, the vector/scalar Poisson CDF gates, the discrete inversion,
  Poisson huge-lambda, noncentral-t, binomial walk, HIN, tightened 1e9
  long-run, truncated-normal/uniform, noncentral/GPD/SICS, hypergeometric
  variance, heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

The independent long-run evidence is
`compare/results/s4-m1703-1e9-long-run-refresh.md` (1e9) and the S4-M1705
`--long 10000000` run with the new binomial gates.
