# S4-M1723 1e9 Long-Run Refresh After The AD Fill And Sampler Caches

Date: 2026-11-16

## Result

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` and exits 0 (about 70 minutes) with
the S4-M1716..S4-M1721 changes present:

- the cached `VectorBinomial` non-dyadic CDF (stream-preserving),
- the cached `VectorPoisson` small-lambda CDF (stream-preserving),
- the cached `VectorHypergeometric` CDF (stream-preserving),
- the S4-M1721 Ahrens-Dieter CDF fill (`fillPoisson(20)` gates at `15`, `20`,
  and `25`),
- the Zipf fill/sample CDF gates and the five dyadic vector binomial gates.

The run covers the full long gate set: discrete CDFs, cached binomial,
huge hypergeometric, negative-binomial mixture, beta huge, continuous CDFs,
tails, and copulas.

## Sample Output

```
long discrete cdf: binomial(4)=0.237514 poisson(5)=0.615957
  hypergeometric(2)=0.372835 negative-binomial(3)=0.656237
  geometric(2)=0.640005 zipf(2)=0.588979 zeta(1)=0.745432
  bernoulli(0)=0.700006
long cached binomial cdf: inversion(12)=0.575974 hin(100)=0.526570
long hypergeometric huge cdf: below=0.252478 (cdf 0.252492)
  above=0.747515 (cdf 0.747508)
long negative-binomial mixture cdf: empirical=0.500289 (cdf 0.500275)
long beta huge cdf: lower=0.002338 (cdf 0.002339)
  upper=0.997660 (cdf 0.997661)
long tails: normal=0.002698 exponential=0.049782
  student-t=0.030104 (expected 0.030099)
long copula 1% joint lower-tail rates: gaussian=0.001875
  student-t=0.003913
distlongcheck ok (1000000000 samples)
```

## Changed Files

- `compare/results/s4-m1723-1e9-long-run-refresh.md`: this evidence file.
