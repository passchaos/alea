# S4-M1809 Bound the Wrapped Normal Image Loop

Date: 2026-11-20

## Gap

`WrappedNormalCdfCache` looped over all `[-k_max, k_max]` images (seven for
`sigma = 1`) and computed two divisions plus the skip test for each, even
though images whose whole `z`-range lies beyond the 9-sigma saturation band
are always skipped. S4-M1796 applied the same bound to the wrapped
skew-normal cache but not here; the wrapped normal quantile measured
3.49-3.56M quantiles/s.

## Change

`init` computes the inclusive image range from the parameter-only endpoint
coordinates (`k_lo = max(-k_max, floor((-9 - upper_z0)/stride))`,
`k_hi = min(k_max, ceil((9 - lower_z0)/stride))`), and `ensureTerms` / `eval`
loop only over it, with the endpoint-term index starting at `k_lo + k_max`.
The per-evaluation skip test stays for the boundary images. The public
`wrappedNormalCdf` shares the cache, so it benefits too.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped normal quantile` | 3.487, 3.559, 3.562 | 4.481, 4.545, 4.623 |

About +28% with an unchanged checksum.

## Correctness audit

Round-trip over 2000 probabilities for `(mu, sigma) = (0, 0.5), (0.4, 1),
(-2, 2), (3, 3), (0, 9.5)`: worst `|CDF(q) − p|` is `7.16e-13` for the
concentrated cases and `5.00e-10` for `sigma = 9.5`, identical to the
pre-change values.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps and long-run evidence current; the wrapped
skew-normal quantile remains the slowest row.
