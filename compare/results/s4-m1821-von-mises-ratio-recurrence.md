# S4-M1821 Single-Division von Mises Ratio Recurrence

Date: 2026-11-20

## Gap

Both the von Mises CDF cache build and the direct CDF walked the backward
Bessel-ratio recurrence with two divisions per step
(`rho = 1/(2k/κ + rho); ratio /= rho`). The quantile cache pays the build once
per call and the direct path pays it per CDF evaluation; the quantile measured
3.1-3.7M quantiles/s and the public CDF 9.1-10.7M calls/s.

## Change

The step is rewritten as `t = 2k/κ + rho; ratio *= t; rho = 1/t`, which is
algebraically identical (`ratio /= rho` is `ratio·t`) but needs one division
and one multiply instead of two divisions — and one fewer rounding.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `von mises cdf` | 9.107, 10.587, 10.711 | 10.465, 11.275, 11.428 |
| `von mises quantile` | 3.102, 3.359, 3.395, 3.521, 3.570, 3.743 | 3.419, 3.448, 3.519, 3.700, 3.725, 3.780 |

About +7% on the CDF and +2-4% (median) on the quantile, with unchanged
checksums.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
