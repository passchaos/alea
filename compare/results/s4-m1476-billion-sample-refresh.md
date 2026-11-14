# S4-M1476 Billion-Sample Refresh With the Huge-Parameter Gates

Date: 2026-11-14

`zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` with the huge-parameter long-run gates
active.

- The unchanged discrete, cached-binomial, continuous, tail, and copula gates
  reproduce the S4-M1455 values: `binomial(4)=0.237505`,
  `poisson(5)=0.615949`, `hypergeometric(2)=0.372840`,
  `negative-binomial(3)=0.656260`, `cached inversion(12)=0.575975`,
  `cached hin(100)=0.525687`, `gamma(3)=0.450579`,
  `normal tail=0.002698`, `student-t tail=0.030104`, and
  `Gaussian copula=0.001875`.
- The new huge-parameter gates pass: tiny-p binomial, huge fair binomial,
  huge-population hypergeometric (H2PE and inverse transform), and the
  negative-binomial gamma-Poisson mixture. The tiny-p gate uses
  `[19.9, 20.1]` to tolerate the documented `+0.015` HIN small-p offset.
- The run takes about 22 minutes on this host because the five huge gates add
  `5e9` O(1) draws.
