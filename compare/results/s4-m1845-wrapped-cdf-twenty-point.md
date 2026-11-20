# S4-M1845 Twenty-Point Owen Rule in the Wrapped Skew-Normal CDF

Date: 2026-11-20

## Gap

The public wrapped skew-normal CDF built the 24-point Owen geometry table
on every call and ran 24 exponentials per point and endpoint term. For
`|alpha| <= 2` the 20-point rule is accurate to about 6e-13 — far below the
wrapped CDF's own Abramowitz-Stegun floor — and S4-M1844 had already shown
that switching the public skew-normal CDF to it is worth 60-100% there.

## Change

`wrappedSkewNormalCdfF64` now builds the 20-point table and routes the
point and endpoint terms through `skewNormalUpperTailZWithGlTable20` /
`skewNormalCdfZWithGlTable20` when `0 < |alpha| <= 2`; wider shapes keep the
24-point table, and `|alpha| > 6` keeps the generic path.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
`wrapped skew-normal cdf` 4.665, 5.027, 5.428, 5.355 M/s before and 6.126,
6.185, 5.922, 5.051 M/s after (median 5.191M to 6.024M, about +16%; three
of four pairs).

## Accuracy

Against the generic-path reference over `sigma ∈ {0.2, 0.5, 1, 2, 3, 6,
9}`, `alpha ∈ {−2, −1, −0.5, 0.5, 1, 2}`, and 401 interior points, the
worst difference is 4.44e-16 (two ulp) — the rule change is invisible at
the CDF's accuracy.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal CDF is now about 6M cdf/s. Keep the no-known-gaps
and long-run evidence current; the large-hypergeometric codegen gap
(0.86-0.87x) remains the only sub-parity comparable workload.
