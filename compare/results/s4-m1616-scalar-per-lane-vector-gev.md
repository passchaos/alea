# S4-M1616 Scalar-Per-Lane Vector GEV Sampling

Date: 2026-11-15

## Probe

After S4-M1615 added the GEV rows, the vector row (15.5-15.8 M vectors/s =
62-63 M samples/s) lagged the scalar row (77-81 M samples/s): the packed path
draws one SIMD `Exp(1)` and then pays a per-lane `@log` plus the pure-Zig
`expm1`. Replaced `VectorGeneralizedExtremeValue.sampleFrom` with four scalar
`generalizedExtremeValuePointFrom` calls (the S4-M1586 vMF pattern) and removed
the now-unused `generalizedExtremeValueFromExponentialVector` helper.

## Bracketed A/B

| Row | Packed SIMD exponential (baseline) | Scalar per lane |
| --- | --- | --- |
| `alea vector generalized extreme value f64x4` | 15.5-15.8 M vectors/s | 18.1-19.7 M vectors/s (+15-25%) |
| `alea generalized extreme value` | 76.9-80.2 M samples/s | 69.9-84.5 M samples/s (run-to-run band) |

The vector checksum changes `6259721.691` -> `6257077.882` (the vector stream
now consumes four scalar exponential draws instead of one SIMD draw); the
scalar checksum stays `393793.141`.

Unlike the S4-M1607 von Mises scalar-per-lane probe, which cost the scalar row
16-20% through code layout, the GEV scalar row stays inside the run-to-run
band, so the change is adopted. The vector row now matches scalar per-sample
throughput (18.1-19.7 M vectors/s = 72-79 M samples/s).

## Validation

- `zig build test -Dtest-filter=GeneralizedExtremeValue --summary all`: 6/6
  GEV tests pass, including the f64x4/f32x8 vector tests.
- `zig build test distcheck --summary all`: 971/971 (native 950/950).
- `zig build statcheck --summary all`: passes (2/2).
- The scalar GEV path is unchanged since the S4-M1615 1e9-sample run
  (`distlongcheck ok (1000000000 samples)`); the vector stream change is
  covered by the vector unit tests.

## Changed Files

- `src/distributions.zig`: scalar-per-lane `VectorGeneralizedExtremeValue`
  sampling; dead packed-vector helper removed; doc comments updated.
- `docs/core-guide.md`: records the scalar-per-lane vector GEV path.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the vector stream
  change.
