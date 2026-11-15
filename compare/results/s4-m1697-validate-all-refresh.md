# S4-M1697 Validate-All Refresh After S4-M1696

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the vector hypergeometric CDF scan present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the hypergeometric CDF scan runs on wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the six dyadic vector geometric pmf gates, the
  fair/dyadic/non-dyadic binomial gates, the `VectorBinomial(200, 0.4)` and
  `VectorBinomial(128, 0.999)` CDF gates, the `fillBinomial(1000, 0.012)`
  CDF gates, the `fillZipf(10, 1.5)` and `VectorZipf(10, 1.5)` CDF gates,
  the `VectorHypergeometric(100, 30, 10)` CDF gates at `2`, `3`, and `5`,
  the negative-binomial CDF/mean gates, the zeta and vector zeta CDF gates,
  the `VectorPoisson(lambda=4)` and `fillPoisson(lambda=4)` CDF gates, the
  discrete inversion, Poisson huge-lambda, noncentral-t, binomial walk, HIN,
  tightened 1e9 long-run, truncated-normal/uniform, noncentral/GPD/SICS,
  hypergeometric variance, heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950), including the vector hypergeometric
fill-vs-loop test.
