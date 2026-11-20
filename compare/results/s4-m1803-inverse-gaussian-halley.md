# S4-M1803 Inverse-Gaussian Quantile Halley Step

Date: 2026-11-20

## Gap

The inverse-Gaussian quantile ran plain Newton. A Halley step was tried
during the S4-M1791 work and rejected because it returned a spurious root at
`p = 0.0795` (`x = 0.00797` with `CDF = 1.3e-55` instead of `x = 0.33136`).
That failure was the far-tail curvature degeneration later identified and
fixed generically by the S4-M1797 dominance guard.

## Change

The loop now takes a Halley step with the standard guard: the slope term must
dominate the curvature term (`2 f'^2 >= |f f''|`), the candidate must stay
inside the bracket, and Newton remains the base step with bisection fallback.
The inverse-Gaussian density derivative is
`f' · (−3/(2x) − λ(1 − μ²/x²)/(2μ²))`.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `inverse-gaussian quantile` | 2.909, 2.910, 2.967, 3.083 | 3.209, 3.267, 3.316, 3.317 |

About +10% with an unchanged checksum.

## Correctness audit

- The previously failing point `p = 0.0795` now returns `x = 0.33136`
  (`CDF = 0.0795`), matching a 200-step bisection reference.
- Round-trip over 2000 probabilities for `shape ∈ {0.5, 1, 2, 10, 100}`:
  worst `|CDF(q) − p| = 3.77e-15`.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
remains the slowest row, followed by the skew-normal and von Mises quantiles.
