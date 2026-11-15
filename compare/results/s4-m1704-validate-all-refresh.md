# S4-M1704 Validate-All Refresh After S4-M1701/S4-M1702

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1929/1929
tests with the multi-word geometric fix and the Zipf fill gate fix present:

- native `alea-tests` 951/951 (the new `vector geometric dyadic multi-word
  lanes stay exact` regression test),
- WASI Node tests 950/950,
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the six dyadic vector geometric pmf gates, the
  fair/dyadic/non-dyadic binomial gates, the large/extreme vector binomial
  CDF gates, the `fillBinomial(1000, 0.012)` CDF gates, the
  `fillZipf(10, 1.5)` and `VectorZipf(10, 1.5)` CDF gates, the vector
  hypergeometric and `fillHypergeometric(100, 30, 10)` CDF gates, the
  negative-binomial CDF/mean gates, the zeta and vector zeta CDF gates, the
  `VectorPoisson(lambda=4)` and `fillPoisson(lambda=4)` CDF gates, the
  discrete inversion, Poisson huge-lambda, noncentral-t, binomial walk, HIN,
  tightened 1e9 long-run, truncated-normal/uniform, noncentral/GPD/SICS,
  hypergeometric variance, heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

The independent 1e9 long-run evidence is
`compare/results/s4-m1703-1e9-long-run-refresh.md`
(`distlongcheck ok (1000000000 samples)`).
