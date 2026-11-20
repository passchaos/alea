# S4-M1787 Owen T Far Tail for Large |a|

Date: 2026-11-20

## Gap

`owenT` used the far-tail closed form only when `|a| <= 6`. For `|a| > 6` it
fell through to the adaptive Simpson path even when `|h·a|` was large and the
tail term is astronomically small. The wrapped skew-normal evaluation calls
`owenT(z, alpha)` with the user's shape, so shapes above 6 hit the recursive
path for every image: `wrappedSkewNormalQuantile(p, 0.4, 1, 20)` measured
about 107 us per call and `alpha = 100` about 90 us, versus about 2.8 us at
`alpha = 2`.

## Change

After the `|a| <= 6, |h| <= 6` box, the far-tail closed form is now used for
any `|h·a| >= 6`, regardless of how the product splits. The identity
`T(h, a) = Q(h)/2 − tail` only needs `|h·a|` large for the tail expansion; the
`Q(h)` term is already computed accurately for every `h` (the incomplete
gamma for `h < 6`, the Mills ratio above). The adaptive Simpson path keeps the
remaining small-`|h·a|` cases. The Owen T test now also checks `|a| ∈ {10, 50}`
with `|h| ∈ {0.5, 1, 2}` against the adaptive reference at `1e-12`.

Validation of the extension against a composite 16x24 Gauss-Legendre
reference over `h ∈ (0, 6]`, `a ∈ [6, 60]` with `h·a >= 6`: worst absolute
difference `2.76e-13`. At the `h·a = 6` edge the tail term itself is below
`1e-11`, so the series' `1/λ` truncation cannot reach the CDF contract.

## Measurements

Direct `wrappedSkewNormalQuantile(p, 0.4, 1, alpha)` timing probe, same host,
old (S4-M1786) versus new binary:

| Shape | Before | After |
| --- | --- | --- |
| `alpha = 0.5` | 2353 ns | 2055 ns |
| `alpha = 2` | 2843 ns | 2566 ns |
| `alpha = 6` | 3744 ns | 3525 ns |
| `alpha = 20` | 107390 ns | 24568 ns |
| `alpha = 100` | 90101 ns | 7485 ns |

The benched `alpha = 2` row is unchanged by this step (its shape is inside the
Gauss-Legendre box); the win is the large-shape cliff, 4.4x at `alpha = 20`
and 12x at `alpha = 100`. The remaining `alpha = 20` cost is the one image
with `|h·a| < 6` per evaluation.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the wrapped skew-normal quantile
is now 0.45-0.46M quantiles/s and the remaining slow rows are its CDF and the
`alpha > 6` small-`h·a` image.
