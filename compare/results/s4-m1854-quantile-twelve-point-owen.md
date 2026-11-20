# S4-M1854 Twelve-Point Owen Rule in the Skew Quantile Paths

Date: 2026-11-20

## Gap

The plain and wrapped skew-normal quantiles solve their Halley/Newton loops
through the 20-point Owen T rule, whose per-image cost is 20 exponentials.
The public CDFs need the 20-point rule's 6e-13 accuracy (1e-12 diagnostics
contract), but the quantile paths only promise a 1e-9 round trip, so the
quantile-only rule can be cheaper. A previous 10-point probe was rejected
for the public CDF because its worst error (1.26e-11 at `h = 0.6`, 8.2e-11
over the full domain) exceeds that 1e-12 contract.

## Accuracy Audit

Fixed-rule `T(h, a)` against the 24-point rule over `|a| <= 2`,
`|h| <= 6.5`, excluding the far-tail branch (`h >= 3` and `h·a >= 6`):

| Rule | Worst absolute error | Location |
| --- | --- | --- |
| 10-point | 8.204e-11 | `a = 2.00`, `h = 1.72` |
| 12-point | 1.546e-12 | `a = 2.00`, `h = 1.83` |
| 16-point | 5.655e-16 | `a = 2.00`, `h = 2.01` |
| 20-point | 1.110e-16 | `a = 1.99`, `h = 0.21` |

The 12-point rule is 53x more accurate than the 10-point rule and still
uses 12 instead of 20 exponentials per Owen T evaluation. The 10-point
rule's 8.2e-11 worst case could accumulate to about 5e-10 through the
wrapped image sum, so the 12-point rule keeps the quantile contract margin
while removing 40% of the rule cost. A 10-point variant is not adopted.

## Change

Added `OwenTGlTable12` / `owenTGlTable12` / `owenTGlTableEval12` /
`owenTWithGlTable12` / `skewNormalCdfZWithGlTable12` /
`skewNormalUpperTailZWithGlTable12`, mirroring the 20-point helpers. The
plain `skewNormalQuantile` and the `WrappedSkewNormalCdfCache` use the
12-point table for `0 < |alpha| <= 2` (the wrapped quantile also for its
pre-step); the public skew-normal and wrapped skew-normal CDFs keep the
20-point rule. The quantile CDF noise floor for the 12-point rule is
2e-12 (was 5e-12 for the 20-point rule in the wrapped cache and 1e-12 in
the plain skew quantile).

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216 "skew-normal quantile"`), four
alternating pairs. Every candidate run is above every baseline run:

| Row | Baseline (M/s) | Candidate (M/s) |
| --- | --- | --- |
| `alea skew-normal quantile` | 3.374, 3.833, 4.183, 3.711 | 5.376, 5.603, 5.615, 5.617 |
| `alea wrapped skew-normal quantile` | 1.558, 2.048, 1.973, 1.854 | 2.088, 2.278, 2.158, 2.166 |

Medians: skew-normal quantile 3.77M -> 5.61M (about +49%); wrapped
skew-normal quantile 1.91M -> 2.16M (about +13%). Checksums are unchanged
(`2174.360`, `4282.426`). The wrapped row gains less because its per-call
cost also carries the endpoint-term setup, the density/derivative pass, and
three `normCdf` calls per image.

## Accuracy

- Wrapped contract grid (9 sigmas x 15 shapes x 4 locations x 13
  probabilities): worst round-trip `|cdf(q) - p|` is 5.014e-10, bit-equal
  to the baseline grid (the worst point is pre-existing at
  `sigma = 0.5, alpha = -1, mu = 0.4, p = 0.75`).
- Plain skew round-trip grid (16 shapes, `p` from 1e-9 to 1 - 1e-6):
  worst relative error 8.889e-6, identical to the baseline.
- A 2080-point quantile value diff shows 752 changed values. The largest
  absolute change is 4.79e-7 at `sigma = 0.5, alpha = 0.25, p = 1 - 1e-6`,
  where the wrapped density is about 3e-6, so the 1.6e-12 rule difference
  maps to that `x` shift; the pre-existing CDF approximation floor is many
  orders larger in that region. For `|q| > 1e-6` the worst relative change
  is 3.2e-7 (deep wrapped tails), and only 21 of 2080 values move by more
  than 1e-8 relative.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.

## Next Bar

The long-run 1e9 distcheck refresh is running; then keep the
no-known-gaps evidence current. The large-hypergeometric codegen gap
(0.86-0.95x) remains the only sub-parity comparable workload.
