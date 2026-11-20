# S4-M1818 Reuse the Exponential for `P(1, y)` in the Hoyt and Marcum Kernels

Date: 2026-11-20

## Gap

Both the Hoyt CDF series and the Marcum P1 recurrence compute
`exp(-y)` and `-expm1(-y)` for the same `y` on every evaluation, paying two
transcendentals where `P(1, y) = 1 - e^-y` needs one. The Hoyt quantile
measured 3.6-4.2M quantiles/s and the Rice quantile 3.9-4.2M.

## Change

- Hoyt series: `p_gamma = 1 - exp_neg_y` reusing the `exp(-ay)` the series
  already needs.
- `marcumP1Recurrence`: `p_gamma = 1 - exp_neg_y` reusing the `exp(-y)` used
  for `gamma_pdf`.

Both are mathematically identical; the only difference is that the direct
subtraction loses relative precision for tiny `y`, where the absolute error
stays near 1e-16.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `hoyt quantile` | 3.643, 3.737, 3.853, 3.942, 4.094, 4.184 | 4.141, 4.757, 4.782, 5.024, 5.154, 5.175 |
| `rice quantile` | 3.921, 4.055, 4.157 | 5.363, 5.733, 5.858 |

About +20-27% for the Hoyt quantile and +32-40% for the Rice quantile, with
unchanged checksums. The public Hoyt and Rice CDFs share the same kernels and
benefit as well.

## Correctness audit

- Hoyt round-trip over 2000 probabilities for `q ∈ {0.01, 0.1, 0.5, 1}` is
  unchanged (the pre-existing `q = 0.01` series-convergence limit remains).
- Rice round-trip over 2000 probabilities for `nu ∈ {0.1, 1, 5, 20}` stays at
  `7.82e-12`.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest Alea-only row.
