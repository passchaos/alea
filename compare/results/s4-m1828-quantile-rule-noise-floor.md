# S4-M1828 Stop Quantile Iterations at the Owen Rule Noise Floor

Date: 2026-11-20

## Gap

The skew-normal quantile and the wrapped skew-normal quantile both stop
their safeguarded Halley loop when the correction `|f − p| / d` falls below
the x tolerance (`1e-12`). The CDF they evaluate is a fixed Gauss-Legendre
Owen T rule with a small *absolute* error — about 6e-13 for the 20-point
rule. Below that floor `f − p` is dominated by rule noise, so the extra
iterations cannot improve the root; they only walk the bracket down while
the noise-limited correction stalls.

A test-only counter showed the skew-normal quantile averaging 5.39
iterations per call at `alpha = 1`, with Halley accepted on 90% of steps —
the loop was converging, then spinning on rule noise.

## Change

Both stop tests now allow for the rule's absolute CDF error:

`|f − p| <= d * tol + min(rule_floor, p * 1e-5)`

with `rule_floor = 1e-12` for the 20-point rule, `1e-14` for the 24-point
rule, and `0` for the generic Owen T path. The `p * 1e-5` cap keeps the
deep tails at their relative accuracy: for `p = 1e-18` the allowance is
`1e-23`, so the far-tail iterations are unchanged.

## Accuracy

- Skew-normal round trip (`CDF(quantile(p)) − p` relative) over `alpha ∈
  {−10, −6, −2, −1, −0.5, 0, 0.5, 1, 2, 3, 6, 10}` and `p` from 1e-18 to
  `1 − 1e-9`: worst 6.35e-13 (`alpha = −2`, `p ≈ 1`), matching the
  documented 3.99e-13 / 5.88e-13 baseline.
- Wrapped skew-normal contract over the S4-M1824 grid: worst round-trip
  error 5.49796e-11, identical to the value before this change (the
  endpoint clamp dominates).
- The deep-tail unit test (`p = 1e-9 … 1e-18`, relative 5e-4) still passes;
  a pre-existing far-tail limit at `alpha = 0.5`, `p = 1e-18` was confirmed
  identical with the floor disabled, so it is not introduced here.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `skew-normal quantile` | 2.639, 2.946, 2.979 | 3.043, 3.138, 2.999 |
| `wrapped skew-normal quantile` | 0.839, 0.860, 0.859 | 0.892, 0.907, 0.906 |

Every paired run favors the floor: about +3% on the skew-normal quantile
and +5.5% on the wrapped skew-normal quantile, with identical checksums.
An earlier unscaled-floor variant measured +4.3% and +6.5% but lost
relative accuracy at `p = 1e-18`; the scaled form keeps most of the win
without that cost.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The slowest Alea-only rows are now the wrapped skew-normal quantile (about
0.91M/s) and the skew-normal quantile (about 3.0M/s). Keep the
no-known-gaps and long-run evidence current.
