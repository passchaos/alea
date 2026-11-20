# S4-M1819 Direct-Form Hoyt Density

Date: 2026-11-20

## Gap

`hoytPdfImpl` computed the density in log space:
`log(2ax) + log(2q/(1+q²)) − ax² + logI₀(r·a·x²)` followed by an `exp`. The
quantile calls it every iteration; after S4-M1818 made the CDF cheaper, the
density's two logs, log-Bessel series, and exponential dominated the
per-iteration cost. The Hoyt quantile measured 4.2-5.2M quantiles/s.

## Change

For the moderate range (`z = r·a·x² <= 30` and `-a·x² > -700`) the density
uses the direct form
`(2ax)·(2q/(1+q²))·exp(−a·x²)·I₀(z)` — one `exp` plus the I₀ power series.
The log-space path remains for larger Bessel arguments or extreme exponents.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `hoyt quantile` | 4.248, 5.162, 5.175, 5.205 | 6.087, 6.128, 6.150, 6.154 |

About +19-45% (median +19%) with every direct run above every log-space run
and an unchanged checksum.

## Correctness audit

The Hoyt round-trip audit is unchanged; the pre-existing `q = 0.01`
series-convergence limit remains (recorded in S4-M1797/M1818).

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
