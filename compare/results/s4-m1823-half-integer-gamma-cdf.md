# S4-M1823 Half-Integer Gamma CDF Recurrence

Date: 2026-11-20

## Gap

For half-integer shapes (`a = 0.5, 1.5, 2.5, ...`) the regularized lower
incomplete gamma still went through the generic paths: the series for
`x < a + 1` and the Lentz continued fraction for `x >= a + 1`. The continued
fraction costs 20-40 division-heavy iterations on the upper side, which is
exactly where the odd-df chi-squared CDF and quantile evaluate
(`chiSquaredCdf(x, dof) = gammaIncompleteP(dof/2, x/2)`).

## Change

`gammaIncompleteP` now dispatches half-integer shapes in the
`a <= x <= 8` band to `gammaHalfShapeP`, which anchors at the exact
`P(1/2, x) = erf(√x)` (the existing erf Taylor) and walks the recurrence
`P(a+1, x) = P(a, x) − e^{-x} x^a / Γ(a+1)` for `a = a2/2` (`a2` odd).
The `a <= x` gate keeps the subtraction `erf(√x) − e^{-x}·sum` well
conditioned (for `x ≪ a` the two terms nearly cancel), and the `x <= 8`
bound keeps the erf Taylor inside its accurate range. Integer shapes are
excluded by the odd check on `2a`.

Side effect: the `a = 0.5` branch previously used the continued fraction for
`4.5 < x < 18`; in the new band that case now shares the same erf Taylor
anchor, which is both faster and slightly more accurate there.

## Accuracy

Checked against an f128 series reference over every half-integer shape
`a ∈ {0.5, 1.5, ..., 7.5}` and 41 points in `[a, 8]`: worst absolute error
2.45e-14 (`a = 7.5`, `x = 7.975`). A permanent regression test compares the
gated path with the generic series at 25 points within 1e-12.

## Measurements

Direct `gammaIncompleteP(2.5, x)` sweep over `x ∈ [2.5, 8]`, 2e7 calls per
trial, best of five, ReleaseFast `-Dcpu=native`, branch enabled/disabled in
the same tree:

| Configuration | ns/call |
| --- | --- |
| generic series/CF | 33.50, 36.85, 33.74 |
| half-integer recurrence | 28.86, 28.57, 28.35 |

About 15-18% faster with the branch.

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `chi-squared quantile` (dof=5) | 3.629, 3.722, 3.512, 3.442, 3.489, 3.487, 3.073 | 4.560, 4.363, 3.303, 4.301, 4.312, 4.294, 4.248 |
| `gamma quantile` (shape=2 control) | 6.278, 6.230 | 6.188, 6.169 |

Median +23% on the chi-squared quantile with identical checksums; the
integer-shape control is flat within noise, confirming the gate only touches
half-integer shapes.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
