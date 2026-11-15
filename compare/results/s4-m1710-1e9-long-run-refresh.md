# S4-M1710 1e9 Long-Run Refresh With The New Gates

Date: 2026-11-16

## Result

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` and exits 0 (about 61 minutes) with
the S4-M1705 dyadic binomial gates and the S4-M1707 HIN fill gate present.

This is the first 1e9 run that covers:

- the five dyadic vector binomial pmf gates (`p = 0.0625`, `0.125`, `0.25`,
  `0.375`, `0.75`),
- `fillBinomial(10000, 0.01)` CDF gates at `90`, `100`, and `110`,
- the six dyadic vector geometric pmf gates,
- the vector binomial fair/non-dyadic gates, the large/extreme vector
  binomial gates, and `fillBinomial(1000, 0.012)`,
- the Zipf, vector Zipf, vector hypergeometric, and
  `fillHypergeometric(100, 30, 10)` gates,
- the vector/scalar Poisson CDF gates, zeta/vector zeta, and the existing
  discrete/continuous/tail/copula gates.

## Sample Output

```
long discrete cdf: binomial(4)=0.237516 poisson(5)=0.615964
  hypergeometric(2)=0.372874 negative-binomial(3)=0.656254
  geometric(2)=0.640003 zipf(2)=0.588962 zeta(1)=0.745439
  bernoulli(0)=0.700017
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

## Notes

The earlier S4-M1703 run covered the pre-S4-M1705/S4-M1707 gate set; this
run re-validates the same kernels plus the new gates at 1e9. No library code
changed in this milestone.

## Changed Files

- `compare/results/s4-m1710-1e9-long-run-refresh.md`: this evidence file.
