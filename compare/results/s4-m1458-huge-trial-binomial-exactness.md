# S4-M1458 Huge-Trial Tiny-P Binomial Exactness

Date: 2026-11-14

## Problem

`binomial(trials, p)` was wrong for probabilities below the rounding
threshold of `1 - p` (`p < ~1.1e-16`) and for huge trial counts in the HIN
region. 200,000-draw means before the fix:

| trials | p | true mean | measured mean |
| --- | --- | --- | --- |
| 1e18 | 1e-18 | 1 | 0.0000 |
| 1e18 | 5e-18 | 5 | 0.0000 |
| 1e18 | 1e-17 | 10 | 0.0000 |
| 1e18 | 2e-17 | 20 | 16.6232 |
| 1e18 | 1e-16 | 100 | 92.1808 |
| 1e19 | 5e-18 | 50 | 44.4879 |

Two causes:

1. The waiting-time rate `-log(1 - p)` rounds to zero when `1 - p == 1`, so
   the `mean < 16` branch always returned zero.
2. The HIN acceptance compares `lf - lfx`, sums of log-factorials of magnitude
   `t · log t`; once `trials - np` reaches about 1e12 the cancellation error
   (`eps · t · log t`) destroys the O(1) ratio and biases the rejection.

## Fix

- The waiting-time rate and the HIN residual-tail rate use `log1p` when
  `1 - x == 1`. The branch preserves the existing stream for ordinary
  probabilities.
- The HIN acceptance for `trials - np >= 1e12` uses a stable log-ratio: the
  `np`-side bracket via the table (`np < 512`), the Stirling difference
  (`np < 1e9`), or the three-term series (`np >= 1e9`); the `t`-side bracket
  uses `x · log(t - np) - x² / (2 · (t - np))`.

## After

The same probe now measures means `1.0022`, `4.9989`, `9.9908`, `20.0075`,
`100.0058`, and `50.0121`, all within statistical noise.

## Validation

- New `binomial huge-trial tiny-p means stay exact` test: 20,000 draws for
  each case with 8.5-14 sigma tolerances.
- `zig build test --summary all` passes 911/911 tests (native `alea-tests`
  892/892), `distcheck`, `statcheck`, and the 10M long run pass, and the full
  16MiB benchmark suite keeps all 457 checksums identical.

## Known Follow-Up

`binomialCdf`/`binomialQuantile` still route these parameters through the
incomplete beta, which loses precision for huge `n` (for example
`binomialCdf(5e8; 1e9, 0.5)` returns `-0.56`). The next bar is a stable
large-parameter CDF with a documented Poisson fallback for tiny `p` and a
normal/saddlepoint fallback for large `npq`.
