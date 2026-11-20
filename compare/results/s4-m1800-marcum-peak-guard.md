# S4-M1800 Tighter Marcum Recurrence Peak Guard

Date: 2026-11-20

## Gap

The Rice CDF's moderate-parameter path uses the Marcum P1 recurrence, which
stopped only after `k > peak` **and** `term <= sum·eps` with
`peak = half_a2 + 10·√(half_a2 + 1) + 10`. For the harness shape
(`nu = sigma = 1`, `half_a2 = 0.5`) that is about 23 terms, while the
`term <= sum·eps` test already holds around `k ≈ 14` — the peak guard alone
kept the loop running for nine extra terms. The Rice quantile measured
2.31-2.57M quantiles/s (5.54 CDF evaluations per call).

## Change

The recurrence's peak guard is now `half_a2 + 5·√(half_a2 + 1) + 5`, which
still clears the term mode (near `half_a2`) by five standard deviations; the
`term <= sum·eps` test remains the accuracy control. The log-series Marcum
paths keep the old guard (their per-term cost is dominated by
`gammaIncompleteP` and the tightening measured neutral there).

## Accuracy

An 8850-point `(nu, x)` grid (`nu ∈ [0.05, 60]`, `x ∈ [0.01, 60]`, both
geometric) compared the tightened CDF against the previous implementation:
maximum absolute difference `7.77e-16` (one ulp). A Simpson reference built
from the Rice density agrees to `1.9e-3` at the largest `nu·x`, which is the
reference's own leading-order Bessel asymptotic error, not the recurrence's.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `rice quantile` | 2.305, 2.351, 2.565 | 3.292, 3.300, 3.351 |

About +35% with an unchanged checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current; the remaining slow rows are the
wrapped skew-normal quantile (about 0.55M), skew-normal quantile (2.7-2.9M),
and Rice (now 3.3M).
