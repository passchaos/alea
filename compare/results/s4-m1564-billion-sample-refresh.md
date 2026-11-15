# S4-M1564 Billion-Sample Refresh After the Binomial Changes

Date: 2026-11-15

## Scope

Refresh the 1e9-sample distribution evidence after the S4-M1550 HIN envelope
correction, the S4-M1556 small-mean inverse-CDF walk, and the S4-M1558/M1560
fill hoists. The previous billion-sample refresh was S4-M1476, before those
changes.

## Command

The ReleaseFast `alea-distcheck` binary was run directly so the host guard's
900-second build-tree timeout does not apply:

```sh
zig build -Doptimize=ReleaseFast distcheck --summary all
.zig-cache/o/<hash>/alea-distcheck --long 1000000000
```

The run takes about 30 minutes on the local aarch64 host.

## Results

`distlongcheck ok (1000000000 samples)`.

- Discrete CDFs: `binomial(4)=0.237505`, `poisson(5)=0.615949`,
  `hypergeometric(2)=0.372840`, `negative-binomial(3)=0.656260`,
  `geometric(2)=0.639990`, `zipf(2)=0.589003`, `zeta(1)=0.745437`,
  `bernoulli(0)=0.699995`.
- Cached binomial: `inversion(12)=0.575974`, `hin(100)=0.526570`.
- Huge gates: hypergeometric `below=0.252478` (cdf `0.252492`),
  `above=0.747515` (cdf `0.747508`), rare `0.526539` (cdf `0.526562`);
  negative-binomial mixture `0.500289` (cdf `0.500275`); beta huge
  `lower=0.002338` (cdf `0.002339`), `upper=0.997660` (cdf `0.997661`).
- Continuous CDFs: `beta(0.3)=0.579825`, `gamma(3)=0.450579`,
  `student-t(0)=0.499983`, `fisher-f(1)=0.534886`,
  `exponential(0.5)=0.632124`, `log-normal(1)=0.500017`,
  `log-logistic(1.5)=0.499978`, `nakagami(2)=0.745235`,
  `ex-gaussian(2)=0.460424`, `inverse-gaussian(1)=0.627680`,
  `skew-normal(0)=0.250011`, `pert(0.5)=0.500010`, `rice(1)=0.396501`,
  `hoyt(1)=0.662988`.
- Tails: `normal=0.002698`, `exponential=0.049782`,
  `student-t=0.030104` (expected `0.030099`).
- Copula 1% joint lower-tail rates: `gaussian=0.001875`,
  `student-t=0.003913`.

The unchanged S4-M1476 values (`binomial(4)=0.237505`, `gamma(3)=0.450579`,
normal tail `0.002698`, student-t tail `0.030104`, Gaussian copula
`0.001875`) reproduce, so the binomial stream changes did not disturb the
shared empirical gates.

## Validation

- The default ReleaseFast `zig build distcheck` (including the 4e6-draw
  `binomial(1e18, 2e-17)` mean gate) passes before the long run.
- The long run includes the huge-trial binomial, huge fair HIN,
  huge-population hypergeometric, negative-binomial mixture, and huge-beta
  gates at 1e9 samples each.
- No code, stream, or benchmark changed; this milestone is evidence-only.
