# S4-M1666 Vector Geometric Hoisted Field Fill

Date: 2026-11-16

## Change

`VectorGeometric.fill`/`fillFrom` and `VectorGeometricFailures.fill`/`fillFrom`
recomputed `dyadicGeometricFields(p)` and dispatched per vector. The dyadic
field decomposition is now computed once per fill call and the packed-word
kernel `vectorGeometricDyadicFrom` runs per vector. The `p == 1` and
`geometricFailuresSaturates(p)` early returns are unchanged, and non-dyadic
probabilities still fall back to per-vector `sampleFrom`.

This also aligns the fill stream with the vector sampler: `sampleFrom` has used
the dyadic packed-word kernel since S4-M1642, while fill still drew each lane
through the scalar `geometricFrom`/`geometricFailuresFrom` helpers. Fill now
matches repeated `sample` for dyadic probabilities; the fill-vs-loop stream
tests were updated to compare against repeated `sampleFrom` instead of the
scalar helper loop.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`
runs, same-session bracketed A/B on `alea fillVectorGeometric f64x4` (p=0.25):

| Fill path | Throughput | Checksum |
| --- | --- | --- |
| Per-lane scalar `geometricFrom` (HEAD) | 127.7 M vectors/s | `8389255.000` |
| Hoisted dyadic fields (probe) | 221.4-223.9 M vectors/s | `8389752.000` |

The checksum change is the expected stream alignment with `sampleFrom`; the
hoisted row is stable across runs (`223.0` M in the confirmation run).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950), including the updated fill-vs-loop
  stream tests and the vector geometric pmf gate.

## Changed Files

- `src/distributions.zig`: hoisted `dyadicGeometricFields` in both vector
  geometric fill paths and the updated stream-shape tests.
- `bench/throughput.zig`: the `alea fillVectorGeometric f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: records the fill stream change.
