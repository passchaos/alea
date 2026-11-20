# S4-M1798 Fixed-Shape Owen T Gauss-Legendre Geometry Table

Date: 2026-11-20

## Gap

The skew-normal quantile's Halley loop evaluates `Φ(z) − 2·T(z, α)` several
times with a fixed `α`. The Owen T Gauss-Legendre rule rebuilt its 24 node
angles (`θ = ½·b·(1 ∓ node)`, `b = atan(|α|)`) on every call, so each
evaluation paid 24 `cos` calls that depend only on the shape. The row measured
1.43-1.44M quantiles/s after the S4-M1797 guard.

## Change

- `owenTGlTable(alpha)` precomputes `b` and the 24 `1/cos²θ` values once.
- `owenTGlTableEval(h2, table)` evaluates the same fixed rule with one
  multiply per node (`exp(−h²·inv_cos²)`) instead of a cosine and a division.
- `owenTWithGlTable` keeps every other `owenT` branch (far tail, adaptive
  Simpson, `a = ±∞`) unchanged.
- `skewNormalCdfZWithGlTable` mirrors `skewNormalCdfZ`, and the skew-normal
  quantile builds one table when `|α| <= 6` (the only shapes that reach the
  Gauss-Legendre box) and uses the table-aware CDF in its loop.

The public `skewNormalCdf` and every other caller keep the original path.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating guard-only/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `skew-normal quantile` | 1.434, 1.435, 1.437 | 2.933, 2.934, 2.935 |

About 2.04x with an unchanged checksum. Against the pre-guard baseline
(1.57M) the row is 1.87x faster overall while the S4-M1797 correctness fix
stays in place.

## Correctness audit

Round-trip over 1000 probabilities for `alpha ∈ {0.5, 2, 6, 10, -2}`: worst
`|CDF(q) − p|` is `7.13e-13`, identical to the guarded table-free version.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

The wrapped skew-normal quantile also evaluates Owen T with a fixed shape;
it can share the same table.
