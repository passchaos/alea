# S4-M1790 Half-Integer Beta CDF and Quantile Recurrences

Date: 2026-11-20

## Gap

`betaCdf` and `betaQuantile` had exact recurrences only for integer `a` or
`b`. The half-integer family (`b = 1/2` with `a = m + 1/2`, or the mirror)
still went through the generic continued fraction and safeguarded Newton. The
harness diagnostic `beta (2.5, 0.5) quantile` measured 1.12M quantiles/s, the
second slowest row after the wrapped skew-normal quantile.

## Change

- `betaCdfHalfBWithPdf(x, a2)` computes `I_x(a, 1/2)` for half-integer
  `a = a2/2` from the exact base `I_x(1/2, 1/2) = 2·asin(√x)/π` and the
  recurrence `I_x(a+1, b) = I_x(a, b) − x^a(1−x)^b/(a·B(a,b))`, carrying
  `B(a, 1/2)` in the same three-multiply step.
- `betaCdfHalfAWithPdf(x, b2)` is the additive mirror for `I_x(1/2, b)`;
  all its terms are positive, so it keeps full relative accuracy in the upper
  half without a subtraction.
- `betaCdf` uses the subtractive form for `x <= 1/2` and the mirrored additive
  form above it; `betaQuantile` solves with the same pair and mirrors
  `p > 1/2` through `1 − I_{1−y}(1/2, a)`.
- Both shapes are bounded to `0.5..64.5` in half-integer steps, matching the
  existing integer-shape fast paths.

## Accuracy

Compared against the generic `betaIncomplete` over `a2 ∈ {1, 3, ..., 129}`,
`x` from `1e-8` to 1 (both parameter orders): worst CDF difference
`2.81e-14`. Quantile round-trips over 200 probabilities per shape (both
orders): worst `|I_x(a, 1/2) − p| = 5.79e-13`. The mirrored formulations keep
the tails from cancelling (the earlier single-direction version measured
`2.55e-12` CDF and `1.52e-11` round-trip and was replaced before landing).

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `beta (2.5,0.5) quantile` | 1.120, 1.121, 1.124, 1.127 | 6.044, 6.045, 6.152, 6.160 |

About 5.4x with an unchanged checksum. The integer-shape `beta quantile`
(15.8M/s) and the `beta` sampler rows are untouched.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the remaining slow rows are the
wrapped skew-normal quantile and CDF and the ex-gaussian/Rice/von Mises
quantiles.
