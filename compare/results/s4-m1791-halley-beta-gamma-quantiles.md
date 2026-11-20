# S4-M1791 Halley Steps for the Beta and Gamma Quantiles

Date: 2026-11-20

## Gap

The half-integer beta quantile (S4-M1790), the integer-`b` beta quantile, and
the gamma quantile (and chi-squared through it) all ran safeguarded Newton on
their CDFs. Each iteration already had the density available, and the density
derivative is a two-term expression:

- beta: `f' · ((a−1)/y − (b−1)/(1−y))`,
- gamma: `f' · ((a−1)/x − 1/scale)`.

The rows measured 9.5M (half-integer beta), 19.3-21.0M (integer beta),
13.4M (Fisher F through the beta path), 5.2M (gamma), and 3.2M (chi-squared)
quantiles per second.

## Change

- The half-integer and integer-`b` beta quantiles take Halley steps
  (`2 f f' / (2 f'^2 − f f'')`) whenever the denominator is positive and
  finite; a candidate outside the bracket falls back to bisection, exactly as
  before.
- The gamma quantile takes the same step, but only when the CDF value is
  representable (`f > 0`) and keeps the Newton step as its base. The
  large-shape lower tail (`gammaQuantile(1e-300, 1e6, 1)`) evaluates the CDF
  through the large-shape normal approximation, which underflows to zero
  there; the quadratic model is meaningless in that regime and the ungated
  version returned a quantile whose round-trip was off by 173 orders of
  magnitude. With the gate the old Newton sequence is reproduced exactly and
  the existing 1e-8 round-trip test passes.

## Measurements

Same-host A/B with separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `beta (2.5,0.5) quantile` | 5.98, 5.99, 6.18 | 9.53, 9.56, 9.58 |
| `beta quantile` (integer) | 19.33, 19.33, 19.50 | 20.81, 20.96, 21.01 |
| `fisher-f quantile` | 13.35, 13.41, 13.43 | 16.27, 16.29, 16.30 |
| `gamma quantile` | 5.19, 5.21, 5.25 | 6.68, 6.69, 6.69 |
| `chi-squared quantile` | 3.20, 3.21, 3.24 | 3.74, 3.77, 3.78 |

That is about +58% for the half-integer beta, +8% for the integer beta, +22%
for Fisher F, +28% for gamma, and +17% for chi-squared, with unchanged
checksums.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests (including the
  large-shape gamma lower-tail round-trip that the ungated version failed).
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest row, followed by the ex-gaussian/Rice/von Mises quantiles.
