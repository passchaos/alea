# S4-M1509 Long-Run Wishart Moment Gates

Date: 2026-11-15

## Change

`tools/distcheck.zig` `checkLongRun` now samples the allocator-backed
`Wishart` and `InverseWishart` samplers alongside the existing long-run
gates. The gate uses the non-diagonal scale `V = [[2, 0.5], [0.5, 1]]`:

- `Wishart(V, 6)` checks `E[W₀₀]`, `E[W₀₁]`, `E[W₁₁]` in
  `[11.99, 12.01]`, `[2.99, 3.01]`, `[5.99, 6.01]` and `Var(W₀₁)` in
  `[13.4, 13.6]`.
- `InverseWishart(V, 10)` checks `E[X] = V/7`, i.e. `E[X₀₀]` in
  `[0.2807, 0.2907]`, `E[X₀₁]` in `[0.0694, 0.0734]`, and `E[X₁₁]` in
  `[0.1399, 0.1459]`.

Both distributions previously failed these checks: the truncated Bartlett
`L·A` product produced `E[W₁₁] = 5.13`, `Var(W₀₁) = 2.99`, and
`E[X₀₀] = 0.52` instead of `6`, `13.5`, and `0.286`.

## Evidence

`zig build distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)` with the new gates active. The rest of
the long-run output is unchanged:

```
long discrete cdf: binomial(4)=0.237726 poisson(5)=0.616206 hypergeometric(2)=0.372637 negative-binomial(3)=0.655993 geometric(2)=0.639980 zipf(2)=0.588769 zeta(1)=0.745329 bernoulli(0)=0.699903
long cached binomial cdf: inversion(12)=0.575781 hin(100)=0.525774
long hypergeometric huge cdf: below=0.252459 (cdf 0.252492) above=0.747386 (cdf 0.747508)
long hypergeometric huge rare cdf: empirical=0.526723 (cdf 0.526562)
long negative-binomial mixture cdf: empirical=0.500421 (cdf 0.500275)
long beta huge cdf: lower=0.002325 (cdf 0.002339) upper=0.997651 (cdf 0.997661)
long continuous cdf: beta(0.3)=0.579888 gamma(3)=0.450438 student-t(0)=0.499955 fisher-f(1)=0.534954 exponential(0.5)=0.631906 log-normal(1)=0.500164 log-logistic(1.5)=0.499873 nakagami(2)=0.745080 ex-gaussian(2)=0.460348 inverse-gaussian(1)=0.627489 skew-normal(0)=0.250156 pert(0.5)=0.500061 rice(1)=0.396158 hoyt(1)=0.663174
long tails: normal=0.002714 exponential=0.049740 student-t=0.030199 (expected 0.030099)
long copula 1% joint lower-tail rates: gaussian=0.001869 student-t=0.003957
distlongcheck ok (10000000 samples)
```

`zig build distcheck --summary all` (normal sample counts) also passes with
the 20,000-sample Wishart gates added in S4-M1507. No RNG stream changed in
this milestone, so the reproducibility matrix and benchmark checksums are
unchanged.

## Validation

- `zig build distcheck -- --long 10000000` passes.
- `zig build test --summary all` passes 932/932 (native `alea-tests`
  913/913).
