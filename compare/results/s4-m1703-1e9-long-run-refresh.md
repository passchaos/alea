# S4-M1703 1e9 Long-Run Refresh

Date: 2026-11-16

## Result

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` and exits 0 (about 57 minutes). The
`--long 10000000` mode also passes with the same gate set.

The run exercises the long gates with the new S4-M1675..M1699 kernels:

- six dyadic vector geometric pmf gates (`p = 0.0625`, `0.125`, `0.25`,
  `0.375`, `0.5`, `0.75`),
- vector binomial fair/dyadic/non-dyadic pmf gates and the scalar binomial
  gates,
- `VectorPoisson(lambda=4)` and `fillPoisson(lambda=4)` CDF fills,
- `fillBinomial(1000, 0.012)` and the large/extreme vector binomial gates,
- `fillZipf(10, 1.5)` and `VectorZipf(10, 1.5)`,
- `VectorHypergeometric(100, 30, 10)` and `fillHypergeometric(100, 30, 10)`,
- zeta and vector zeta gates,
- the discrete CDF block, cached binomial, huge hypergeometric, negative
  binomial mixture, beta huge, continuous CDFs, tails, and copula gates.

## Sample Output

```
long discrete cdf: binomial(4)=0.237508 poisson(5)=0.615967
  hypergeometric(2)=0.372834 negative-binomial(3)=0.656255
  geometric(2)=0.640027 zipf(2)=0.588981 zeta(1)=0.745435
  bernoulli(0)=0.699992
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

## Failures Found And Fixed

The first two 1e9 attempts failed and produced two fixes:

- S4-M1701: `vectorGeometricDyadicFrom` kept accumulating fields for lanes
  that had already succeeded in an earlier packed word, so `p = 1/16`
  measured `P(X = 1) = 0.0183` against `0.0625` (chi-square 57,059,059).
- S4-M1702: the `fillZipf(10, 1.5)` gate used the `Zipf(40, 1.5)` expected
  CDF; the sampler was correct.

## Changed Files

- `compare/results/s4-m1701-vector-geometric-multiword-fix.md`: the kernel
  fix.
- `compare/results/s4-m1702-zipf-fill-gate-fix.md`: the gate fix.
