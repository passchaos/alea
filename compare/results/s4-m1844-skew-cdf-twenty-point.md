# S4-M1844 Twenty-Point Owen Rule in the Public Skew-Normal CDF

Date: 2026-11-20

## Gap

The public `skewNormalCdf` evaluated every shape through the generic
`skewNormalCdfZ`, whose Owen T builds the 24-node Gauss-Legendre geometry
inline on every call (24 cosines, an atan, and 24 reciprocals) and then
runs 24 exponentials. The row measured 9.7-13.2M cdf/s.

The CDF's own accuracy is dominated by the Abramowitz-Stegun `normCdf`
(about 1.5e-7), so the 20-point rule's 6e-13 error — already adopted for
the skew quantile — is three orders of magnitude below the existing floor.

## Change

For `0 < |alpha| <= 2` the public CDF now builds the 20-point geometry
table and evaluates through `skewNormalCdfZWithGlTable20`; other shapes keep
the generic path. The lower-tail asymptotic branch and the `alpha = 0`
normal limit are untouched.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
`skew-normal cdf` 12.440, 9.725, 13.155, 10.466 M/s before and 20.058,
20.037, 20.332, 20.083 M/s after — a stable 20M/s, roughly +60-100% over the
generic path.

## Accuracy

A grid comparison against the generic path over `alpha ∈ {−2, −1.5, −1,
−0.5, 0.25, 0.5, 1, 1.5, 2}` and 2001 points on `[−40, 40]` shows a worst
difference of 1.11e-16 (one ulp); the 20-point rule's own 6e-13 error stays
far below the CDF's 1.5e-7 A&S floor. The far-left-tail tests (which take
the asymptotic branch) are unaffected.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current. The same gated rule
could be considered for the wrapped skew-normal CDF if its public row needs
more headroom; the large-hypergeometric codegen gap (0.86-0.87x) remains
the only sub-parity comparable workload.
