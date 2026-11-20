# S4-M1824 Saturated Endpoint Terms in the Wrapped Skew-Normal Paths

Date: 2026-11-20

## Gap

Both wrapped skew-normal evaluators sum a per-image pair
`F(z_k(x)) − F(z_end,k)`, where `z_end,k` are the image positions of the
endpoint (`−π` or `π`). The far endpoint images sit 9-15 sigma out, so their
term saturates at 0 or 1 in f64, yet it was still evaluated through the full
tail machinery: for positive `z_end` the upper branch calls
`gammaIncompleteQ(0.5, z_end²/2)` (a continued fraction that needs 30+
iterations at `z = 9`) plus the Owen T far tail, and for negative `z_end` it
goes through `1 − skewNormalCdfZ` with the far-tail series.

The public CDF paid that cost on every call for the endpoint side of each
image; the quantile cache paid it once per call in `ensureTerms` and then
reused the values, but that setup was about 500 ns of the 1.6 µs quantile.

## Change

The endpoint term is now clamped to its limiting value once the endpoint
image leaves the same saturation band the evaluator already uses for the
point term:

- upper branch (`Q_sn`): `0` for `z_end >= band`, `1` for `z_end <= -band`;
- lower branch (`Φ_sn`): `1` for `z_end >= band`, `0` for `z_end <= -band`.

The public CDF keeps its 9-sigma band (`Q_sn(9) < 2.3e-19`), and the
quantile cache keeps its 6.5-sigma band (`Q_sn(6.5) < 8e-11`, far inside
the 1e-9 round-trip contract). No other value changes.

## Accuracy

- Public CDF against the unclamped image sum over `sigma ∈ {0.2, 0.5, 1, 2,
  3, 6, 9}`, `alpha ∈ {−10, −6, −2, −0.5, 0, 0.5, 2, 6, 10}`,
  `mu ∈ {0.4, −1.7}`, and 401 points on `[−π, π]`: worst deviation
  1.11e-16 (one ulp).
- Quantile round trip `CDF(quantile(p))` over the same `sigma`/`alpha` grid
  and `p ∈ {1e-4, 0.01, 0.1, 0.5, 0.9, 0.99, 1−1e-4}`: worst error
  5.50e-11, inside the 1e-9 contract (the existing unit test uses 1e-9).

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal cdf` | 4.165, 4.176, 4.176 | 5.415, 5.521, 5.393 |
| `wrapped skew-normal quantile` | 0.623, 0.635, 0.645 | 0.842, 0.855, 0.837 |

About +30-32% on the CDF and +30-35% on the quantile with identical
checksums. A direct `wrappedSkewNormalQuantile(p, 0.4, 1.0, 2.0)` sweep over
2M probabilities drops from 1625-1726 ns to 1152 ns per call with the same
4.53 average Halley iterations, confirming the win is setup cost and not a
change in the solve.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile moved from about 0.62M to 0.85M
quantiles/s; the solve itself (4.53 Halley iterations at ~156 ns per
evaluation) is now the dominant cost. Keep the no-known-gaps and long-run
evidence current.
