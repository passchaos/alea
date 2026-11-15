# S4-M1685 Validate-All Refresh After S4-M1684

Date: 2026-11-16

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the extended large-trial binomial fill and the extreme-`p`
underflow fallback present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950 (the 1024-trial fill table and binary search run on
  wasm32-wasi),
- native and WASI distcheck with the continuous/tail/copula gates, the GEV
  and von Mises sampler/CDF gates, the scalar/vector binned chi-square gates
  including the six dyadic vector geometric pmf gates, the
  fair/dyadic/non-dyadic binomial gates, the new
  `VectorBinomial(200, 0.4)` CDF gates at `76`, `80`, and `84`, the
  `VectorBinomial(128, 0.999)` CDF gate at `127`, the negative-binomial
  CDF/mean gates, the zeta and vector zeta CDF gates, the
  `VectorPoisson(lambda=4)` CDF gates, the discrete inversion, Poisson
  huge-lambda, noncentral-t, binomial walk, HIN, tightened 1e9 long-run,
  truncated-normal/uniform, noncentral/GPD/SICS, hypergeometric variance,
  heavy-tail mean, Wishart, and long-run gates,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck statcheck --summary all` independently passes 39/39
steps and 973/973 tests (native 950/950).
