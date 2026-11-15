# S4-M1624 Vector Coverage and Per-Lane Continuation

Date: 2026-11-15

## New Rows

Added the remaining continuous vector benchmark rows with the scalar
parameters:

| Row | Packed vectors/s | Scalar samples/s |
| --- | --- | --- |
| `alea vector log-normal f64x4` | 24.5 M | 125.0 M |
| `alea vector skew-normal f64x4` | 48.4-49.6 M | 481.4 M |
| `alea vector pert f64x4` | 16.0 M | 122.3 M |
| `alea vector inverse-gaussian f64x4` | 71.6-72.1 M | 497.0 M |
| `alea vector normal-inverse-gaussian f64x4` | 39.2-40.0 M | 307.9-330.9 M |
| `alea vector triangular f64x4` | 374.4 M | 1010.8 M |
| `alea vector arcsine f64x4` | 38.8 M | 146.4 M |
| `alea vector maxwell f64x4` | 30.7-31.3 M | 236.6 M |

## Adopted: SkewNormal, InverseGaussian, Maxwell

These three vector samplers now call the scalar reusable sampler once per
lane (`self.sampler.sampleFrom(source)`), with `sample`/`fill`/`fillFrom`
delegating:

| Row | Packed | Scalar per lane | Vector checksum |
| --- | --- | --- | --- |
| `alea vector skew-normal f64x4` | 48.4-49.6 M | 114.3-119.8 M (+136-141%) | `1182546.338` -> `1181473.904` |
| `alea vector inverse-gaussian f64x4` | 71.6-72.1 M | 129.6-139.4 M (+80-95%) | `2095806.976` -> `2097630.839` |
| `alea vector maxwell f64x4` | 30.7-31.3 M | 36.2-39.7 M (+18-27%) | `6692438.027` -> `6692788.229` |

The inverse-gaussian infinity-semantics test reference now consumes one scalar
normal plus one scalar uniform per lane.

## Measured, Kept Packed

- PERT: the packed `vectorBetaFrom` path measures 16.0-16.6 M vectors/s
  against 122.3 M scalar samples/s; per-lane scalar beta only matched the
  packed path (+4%, within noise), so PERT keeps the packed beta sampler and
  its checksum (`1048720.135`).
- NormalInverseGaussian: the packed two-normal composition measures
  39.2-41.6 M vectors/s. Delegating its inner inverse-Gaussian to the new
  per-lane `VectorInverseGaussian` regressed it to 16.5 M (-58%), so
  `sampleFrom` keeps the packed `inverseGaussianFromNormalVector` composition
  (matching `sample`/`fill`) and the checksum (`1209421.649`).
- Triangular: packed 374.4 M vectors/s = 1498 M samples/s already exceeds the
  1010.8 M scalar row, so it keeps the packed uniform transform.
- Arcsine: packed 38.8 M = 155 M samples/s already exceeds the 146.4 M scalar
  row, so it keeps the packed transform.
- Log-normal: packed 24.5 M = 98 M samples/s against 125 M scalar; the
  `lognormal-transform-notes.md` bar requires a sound exact-`exp` transform
  candidate before changing this path, so the row is coverage only.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950), including the updated
  inverse-gaussian infinity stream-shape test and the vector support/stream
  test.

## Changed Files

- `bench/throughput.zig`: eight vector rows.
- `src/distributions.zig`: scalar-per-lane `VectorSkewNormal`,
  `VectorInverseGaussian`, and `VectorMaxwell`; the inverse-gaussian infinity
  test reference updated.
- `compare/results/performance-triage.md`: records the adoption and the kept
  packed paths.
- `compare/results/reproducibility-matrix.md`: versions the three vector
  stream changes.
