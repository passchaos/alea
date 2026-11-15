# S4-M1607 Circular von Mises Benchmark Rows and Scalar-Per-Lane Probe

Date: 2026-11-15

## New Rows

The circular von Mises family had no benchmark rows. Added:

- `alea von mises` (`VonMises(f64).new(0.5, 5)`, `bytes / 8`): 37.7-40.2 M
  samples/s;
- `alea vector von mises f64x4` (`VectorVonMises(V4).new(0.5, 5)`,
  `bytes / 32`): 6.8-7.1 M vectors/s (27-28 M samples/s).

The vector API is therefore slower per sample than the scalar sampler on this
host; the row is recorded so the gap is visible.

## Probe (Rejected)

Tried the S4-M1586 scalar-per-lane pattern for `VectorVonMises.sampleFrom`:
four scalar `vonMisesFrom` calls per vector, both inlined and through a
`noinline vonMisesVectorLaneFrom` wrapper.

| Row | Packed vector (baseline) | Scalar per lane |
| --- | --- | --- |
| `alea vector von mises f64x4` | 6.8-7.1 M vectors/s | 8.0-8.3 M vectors/s |
| `alea von mises` | 37.7-40.2 M samples/s | 31.6-32.5 M samples/s |

The vector row gains 14-19%, but the scalar row drops 16-20% through code
layout; the `noinline` wrapper does not protect it. This repeats the
S4-M1346/S4-M1375 Kent lesson: the scalar row is the more valuable one, so
the packed vector von Mises loop stays.

## Validation

- `alea-throughput -- 16777216 "mises"` builds and runs the new rows; the
  reverted tree reproduces the packed-vector checksums
  `2868555713184248257` (scalar) and `13426811416932291154` (vector).
- Benchmark/docs-only: no library code, sampling stream, or public API
  changed.
