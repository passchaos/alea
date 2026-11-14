# S4-M1464 Huge-Population Hypergeometric Envelope

Date: 2026-11-14

## Problem

`hypergeometric(1e18, 1e17, 5e17)` hung. The H2PE setup computes its tail
weights as `exp(a - Σ logfact(...))`, where `a` and the log-factorials are
about `4e19`; the cancellation produced a non-finite `p3`,
`HypergeometricRejectionAcceptance.init` returned null, and the sampler
degraded to the per-draw loop — 5e17 iterations.

## Change

- Added `hypergeometricLogFactorialDelta(b, d)`: a third-order asymptotic
  expansion for `b >= 1e6` and the gamma difference below that.
- Added `hypergeometricLogRatio(...)`, the stable `log(f(y)/f(mode))`;
  candidates beyond 32 envelope radii return `-inf` (their true ratio is
  below `e^{-500}`).
- The H2PE setup computes `k_l`/`k_r` through the stable ratio when
  `max(n1, n2, k) >= 1e12`, and the acceptance fallback uses the same ratio.
  The struct stores `radius` and `stable_tail`; moderate-population paths are
  untouched.

## After

- `H(1e18, 1e17, 5e17)` selects `rejection_acceptance` (previously
  `draw_loop`) and its 20,000-draw mean is `5.000000e16` against the expected
  `5e16`.
- `H(1e18, 5e17, 5e17)` measures `2.500000e17`,
  `H(1e18, 1e17, 1e17)` `1.000000e16`,
  `H(1e12, 5e11, 5e11)` `2.500000e11`, and
  `H(1e6, 5e5, 5e5)` `2.500006e5`.
- The full 16MiB benchmark suite keeps all 457 checksums identical.

## Validation

- New `hypergeometric huge populations stay exact and finite` test checks the
  method selection and the means.
- `zig build test --summary all` passes 914/914 tests (native `alea-tests`
  895/895), `distcheck`, `statcheck`, and the 10M long run pass.
