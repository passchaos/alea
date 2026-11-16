# S4-M1751 1e9 Long-Run Refresh After the Quantile Newton Sweep

Date: 2026-11-16

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` and exits 0 (about 67 minutes).

The run covers the full long gate set after S4-M1731..M1750:

- the scalar/vector wrapped normal binned gates,
- the merged-bin non-dyadic vector binomial gate,
- the six dyadic vector geometric pmf gates and the five dyadic vector binomial
  gates,
- the fair/non-dyadic binomial gates and the large/extreme vector binomial CDF
  gates,
- `fillBinomial(1000, 0.012)` and `fillBinomial(10000, 0.01)`, the Zipf/vector
  Zipf gates, the vector hypergeometric and `fillHypergeometric(100, 30, 10)`
  gates, the `fillPoisson(4)` and `fillPoisson(20)` gates, the zeta/vector zeta
  gates, the vector/scalar Poisson gates, the negative-binomial gates, the
  discrete inversion, Poisson huge-lambda, noncentral-t, binomial walk, HIN,
  truncated-normal/uniform, noncentral/GPD/SICS, hypergeometric variance,
  heavy-tail mean, Wishart, and continuous/tail/copula gates.

No library code changed in this milestone; the quantile Newton changes are
stream-preserving and the CDF gates are unchanged.
