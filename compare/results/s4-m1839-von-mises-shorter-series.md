# S4-M1839 Four Fewer Fourier Terms in the von Mises Cache

Date: 2026-11-20

## Gap

`VonMisesCdfCache.init` truncates the von Mises Fourier series at
`k_sum = min(kappa + 4.5·sqrt(kappa) + 8, 8.5·sqrt(kappa) + 40)`, which is
24 terms at `kappa = 5`. Each term costs a step of the sine/cosine
recurrence in every CDF evaluation and one more ratio step in the setup.
The coefficient at `k = 20` contributes about 7e-14 to the CDF — far below
the quantile's 1e-12 target — so the last four terms were carrying no
useful precision.

## Change

The bound drops four terms: `min(kappa + 4.5·sqrt(kappa) + 4,
8.5·sqrt(kappa) + 36)`. The cache's own setup cost falls by the four
recurrence steps and every CDF evaluation walks four fewer sine terms.

## Accuracy

The round-trip audit (`kappa ∈ {0.5, 1, 2, 5, 10, 20, 50, 100, 500, 5000,
1e4}`, nine probabilities from 1e-6 to `1 − 1e-6`) gives a worst
`|CDF(quantile(p)) − p|` of 1.61504e-12 versus 1.61515e-12 before — the
truncation change is invisible at the quantile's accuracy.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new across two
windows:

| Window | Before (M/s) | After (M/s) |
| --- | --- | --- |
| first | 3.541, 3.717, 3.743, 3.491, 3.717 | 3.854, 3.900, 3.497, 3.599, 3.895 |
| second | 3.186, 3.230, 3.147, 3.210, 3.172, 2.959 | 3.325, 3.359, 3.232, 3.492, 3.291, 3.289 |

Ten of the eleven pairs favor the change; the medians move from 3.717M to
3.854M (about +3.7%) and from 3.179M to 3.308M (about +4.1%).

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The von Mises quantile is now about 3.85M quantiles/s. Keep the
no-known-gaps and long-run evidence current, and revisit the
large-hypergeometric codegen gap (extracting the cold `stable_tail` path
was measured at −7.5% and reverted).
