# S4-M1434 — Billion-sample local distribution check

## Goal

Raise the local statistical-confidence bar from the 10M-sample long sweep to
1e9 samples, covering the discrete, continuous, tail, and copula gates on the
current samplers (including the recent binomial, multinomial, and packed-fill
changes).

## Commands

```
zig build -Doptimize=ReleaseFast distcheck -- --long 100000000
zig build -Doptimize=ReleaseFast distcheck -- --long 1000000000
```

## Results

- `distlongcheck ok (100000000 samples)` in 74.25 s wall time.
- `distlongcheck ok (1000000000 samples)` in 751.07 s wall time.

The billion-sample gates land well inside their tolerances. Representative
values from the 1e9 run:

- discrete CDFs: binomial(4)=0.237505, poisson(5)=0.615949,
  hypergeometric(2)=0.372840, negative-binomial(3)=0.656260,
  geometric(2)=0.639990, zipf(2)=0.589003, zeta(1)=0.745437,
  bernoulli(0)=0.699995,
- continuous CDFs: beta(0.3)=0.579825, gamma(3)=0.450579,
  student-t(0)=0.499983, fisher-f(1)=0.534886, exponential(0.5)=0.632124,
  log-normal(1)=0.500017, log-logistic(1.5)=0.499978, nakagami(2)=0.745235,
  ex-gaussian(2)=0.460424, inverse-gaussian(1)=0.627680,
  skew-normal(0)=0.250011, pert(0.5)=0.500010, rice(1)=0.396501,
  hoyt(1)=0.662988,
- tails: normal=0.002698, exponential=0.049782, student-t=0.030104
  (expected 0.030099),
- copula 1% joint lower-tail rates: gaussian=0.001875,
  student-t=0.003913.

The 1e9 run is 100x the previous 10M bar and 10x the 1e8 run; no gate moved
outside its established tolerance, so the recent sampler changes carry no
detectable distribution drift at this scale.

## Interpretation

This is local execution evidence on the current macOS host. It complements,
but does not replace, the 128GiB PractRand observations recorded in
`compare/results/practrand-observation-followup.md`, which remain unchanged.

## Validation

- `zig build test --summary all` passes 903/903.
- `zig build distcheck` and the 10M long run pass.
- `compare/results/core-rand-coverage.md` S4-M1434 row added.

## Next bar

Second-platform execution (still blocked locally without QEMU/Wine), an even
longer local sweep when a dedicated runner is available, or newly discovered
core gaps.
