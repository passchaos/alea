# S4-M1817 Twenty-Point Owen T Rule for Moderate Skew Shapes

Date: 2026-11-20

## Gap

The skew-normal quantile's Halley loop evaluates one Owen T per iteration
with the fixed 24-point Gauss-Legendre rule (24 exponentials). The row
measured 2.63-2.72M quantiles/s. A previous attempt at a 20-point rule was
rejected because it degraded the `alpha = 6` round-trip from `7.1e-13` to
`7.2e-11` (still inside the 1e-9 contract, but a 100x accuracy loss).

## Change

The 20-point rule is used only for `|alpha| <= 2`, where its worst deviation
from the 24-point rule is about `6e-13` (measured against the 24-point rule
over the `|h| <= 6`, `|a| <= 6` box); wider shapes keep the 24-point table and
the standard path. The table geometry is built once per quantile call for
whichever rule applies.

## Accuracy

The quantile round-trip audit is unchanged in character: `alpha = 0.5` and
`alpha = 2` stay at `3.99e-13` and `5.88e-13`, `alpha = 6` and `alpha = 10`
stay at `7.13e-13` and `7.04e-13`.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), five alternating pairs:

| Rule | Runs (M quantiles/s) |
| --- | --- |
| 24-point | 2.625, 2.633, 2.706, 2.709, 2.715 |
| gated 20-point | 3.133, 3.145, 3.145, 3.235, 3.251 |

About +19-20% with every gated run above every 24-point run and an unchanged
checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
