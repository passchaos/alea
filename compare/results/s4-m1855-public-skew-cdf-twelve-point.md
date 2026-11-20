# S4-M1855 Twelve-Point Owen Rule in the Public Skew CDFs

Date: 2026-11-20

## Gap

S4-M1854 moved the skew quantile paths to the 12-point Owen rule but kept
the public `skewNormalCdf` and `wrappedSkewNormalCdf` on the 20-point rule.
That rule was chosen in S4-M1844/S4-M1845 when 20 points were the cheapest
audited option, but the public CDF's own accuracy is dominated by the
Abramowitz-Stegun `normCdf` (about 1.5e-7), so the extra four nodes were
buying accuracy far below the existing floor. It also meant the CDF and
quantile sides of every round trip used different rules.

## Change

The public skew-normal CDF and the public wrapped skew-normal CDF now build
the 12-point geometry table for `0 < |alpha| <= 2` (worst rule error
1.55e-12 over `|a| <= 2`, `|h| <= 6.5`, audited in S4-M1854). Wider shapes
keep the 24-point rule. The now-unused 20-point table and helpers were
removed.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216 "skew-normal"`), three alternating
pairs. Every candidate skew-CDF run is above every baseline run:

| Row | Baseline (M/s) | Candidate (M/s) |
| --- | --- | --- |
| `alea skew-normal cdf` | 26.778, 20.009, 25.303 | 41.166, 37.853, 28.837 |
| `alea wrapped skew-normal cdf` | 5.987, 5.167, 5.792 | 5.791, 6.311, 6.330 |

Medians: skew-normal CDF 25.3M -> 37.9M (about +50%); wrapped skew-normal
CDF 5.79M -> 6.31M (about +9%, mixed in the first pair and above in the
other two). The quantile rows are unchanged within the run-to-run band
(the quantile paths already used the 12-point rule), and all checksums are
unchanged (`1717.912`, `1462.384`, `2174.360`, `4282.426`).

## Accuracy

- A 393,060-point public CDF grid (`alpha` from -2 to 2, `z` from -40 to 40;
  `sigma` in {0.2, 0.5, 1, 2, 5} for the wrapped CDF) against the S4-M1854
  binary shows a worst change of 3.09e-12 for `skewNormalCdf` and 9.69e-12
  for `wrappedSkewNormalCdf`, about five orders below the CDF's own A&S
  floor (1.5e-7).
- The contract grids are bit-equal to S4-M1854: wrapped worst round trip
  5.014e-10, plain skew worst relative round trip 8.889e-6. CDF and
  quantile now share one rule, so the round trips no longer mix rules.
- A dense round-trip audit (5 sigmas x 8 shapes x 3 locations x 999
  probabilities, 119,880 calls) measures a worst wrapped-skew
  `|cdf(q) - p|` of 8.1e-11 (`sigma = 1`, `alpha = 2`, `mu = 2`,
  `p = 0.501`) and a worst plain-skew error of 5.0e-10 (`alpha = -1`,
  `p = 0.75`), both inside the 1e-9 contract with margin.
- `zig build test --summary all` passes 996/996, including the skew-normal
  reference-value tests and the wrapped monotonicity/round-trip tests.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.

## Next Bar

The long-run 1e9 distcheck refresh is running; then keep the
no-known-gaps evidence current. The large-hypergeometric codegen gap
remains the only sub-parity comparable workload.
