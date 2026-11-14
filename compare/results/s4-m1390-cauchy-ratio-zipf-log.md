# S4-M1390 — Ratio-of-normals Cauchy and one-log Zipf acceptance

## Goal

Replace the two-transcendental Cauchy inverse-CDF transform with the exact
ratio of two independent standard normals, and halve the log count in the Zipf
rejection-inversion acceptance.

## Implementation

- `cauchyFrom` now draws two standard normals and returns
  `median + scale · (X / Y)`. For independent `X, Y ~ N(0,1)`, `X / Y` is
  exactly standard Cauchy, so the sampled law is unchanged. The scalar
  `fillCauchyFrom`/`Cauchy.fill` paths draw the same two normals per element,
  and the `Cauchy.sample` facade method delegates to `cauchyFrom`. The
  vectorized `VectorCauchy` path keeps its `tan` transform.
- `Zipf.nextSampleFrom` evaluates the acceptance as
  `exponent · log(x / inv_b)` instead of `exponent · (log(x) − log(inv_b))`.
  The two forms are algebraically identical, the ratio form pays one log
  instead of two, and the 16Mi focused checksums are unchanged
  (`329448.000` / `330159.000`), so the sampled values are identical.
- The `nonfinite cauchy parameters follow local rand_distr acceptance` test
  reference now consumes two standard normals per sample and per fill element,
  matching the new stream shape.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea cauchy` | 123.3M samples/s | 533-540M samples/s | +332-338% |
| `alea cauchy fast direct` | 127.1M samples/s | 475-528M samples/s | +274-316% |
| `alea cauchy scalar direct` | 137.8M samples/s | 484-540M samples/s | +251-292% |
| `alea fillCauchy` | 187.2M samples/s | 450.1M samples/s | +140% |
| `alea fillCauchy fast direct` | 177.0M samples/s | 452.2M samples/s | +155% |
| `alea fillCauchy scalar direct` | 175.5M samples/s | 502.0M samples/s | +186% |
| `alea zipf direct` | 51.5M samples/s | 54.6-54.8M samples/s | +6% |

The Cauchy checksums shift because the consumed stream changes
(`465377.738` → `36458.106`, scalar direct `9816.115` → `43814.340`); the Zipf
checksums are unchanged. Regression canaries stay in their bands:
`skew-normal` 576.6M, `gamma` 170.2M, `beta` 86.8M.

## Validation

- All Cauchy tests pass, including the nonfinite-parameter stream-shape test
  and the degenerate no-draw test.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, further rejection-loop tuning, or newly discovered
core gaps.
