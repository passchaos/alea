# S4-M1771 Owen T Far-Tail Closed Form

Date: 2026-11-20

## Gap

`owenT(h, a)` used the fixed 12-node Gauss-Legendre rule only for
`|h| <= 3`; beyond that it fell back to `owenTSlow`, an adaptive Simpson
quadrature. A temporary probe that zeroed `owenTSlow` lifted the wrapped
skew-normal CDF from 1.28M to 2.98M cdf/s and the quantile from 0.286M to
0.362M quantiles/s, showing the slow path dominated those rows.

## Change

`src/distributions.zig` now has `owenTFarTail` for `|h| >= 3`, `|a| <= 6`,
`|h·a| >= 6`, using the identity `T(h, ∞) = Q(h)/2`:

```
T(h,a) = Q(h)/2 - e^{-h²(1+a²)/2} / (2π·h²·a·(1+a²)) · (1 - 1/λ + 3/λ² - 15/λ³)
```

with `λ = (h·a)²`. `Q(h)` comes from the Mills-ratio series for `h >= 6` and
from the incomplete-gamma continued fraction (`Q(1/2, h²/2)`) below, matching
the accuracy of the existing upper-tail path. The correction series removes the
`t > a` tail; its truncation error is below 1e-17 for the `|h·a| >= 6` range.

The Owen T accuracy test now also compares the far-tail path against the
adaptive Simpson reference for `h ∈ {3, 3.5, 4, 5, 6, 8, 10}` and
`a ∈ {0.5, 1, 2, 4, 6}`.

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 17179869184 "<filter>"` (4.19M evaluations per row):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea wrapped skew-normal cdf` | 1.277M cdf/s | 2.701M cdf/s | 2.11x |
| `alea wrapped skew-normal quantile` | 0.286M quantiles/s | 0.342M quantiles/s | 1.20x |
| `alea skew-normal cdf` | 3.109M | 3.109M | unchanged (bench stays in the GL range) |
| `alea skew-normal quantile` | 1.016M | 1.016M | unchanged |

Checksums are unchanged: wrapped CDF `1533310.173`, wrapped quantile
`4509979.616`, skew-normal CDF `1801231.193`, skew-normal quantile
`2366017.829`.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests, including the
  extended Owen T far-tail accuracy comparison.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because every recorded
  checksum is identical.

## Next Bar

Continue with the remaining slow sampling rows (vector-directional
kent/bingham/watson) and broaden the platform evidence.
