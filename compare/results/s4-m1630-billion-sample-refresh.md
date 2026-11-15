# S4-M1630 Billion-Sample Refresh After S4-M1628

Date: 2026-11-15

Rebuilt the ReleaseFast `alea-distcheck` from the current tree and ran it at
1e9 samples to validate the `exp2`/`log2` Weibull, Fréchet, GEV, and
log-logistic streams at long scale:

```
./.zig-cache/o/a1c2ddccd6995bd60c696f582ea8272a/alea-distcheck --long 1000000000
```

The run prints `distlongcheck ok (1000000000 samples)` in about 30 minutes
with the GEV mean/`cdf(3.0)` gate, the scalar and vector binned chi-square
gates, the von Mises sampler/CDF gate, the tightened directional gates, and
the discrete/tail/copula gates all passing.

The non-vector values reproduce S4-M1608/S4-M1615/S4-M1626:
`binomial(4)=0.237505`, `poisson(5)=0.615949`,
`negative-binomial(3)=0.656260`, `gamma(3)=0.450579`, normal tail `0.002698`,
student-t tail `0.030104`, Gaussian copula `0.001875`.

Tooling/evidence-only: the sampled values of the four families change only at
the ulp level (S4-M1628) and their streams are versioned in
`reproducibility-matrix.md`; no library code changed for this refresh.
