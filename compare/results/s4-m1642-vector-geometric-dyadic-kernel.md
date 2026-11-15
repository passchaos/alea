# S4-M1642 Vectorized Dyadic Geometric Kernel

Date: 2026-11-15

## Change

`VectorGeometric` and `VectorGeometricFailures` ran the scalar sampler once
per lane. Added `vectorGeometricDyadicFrom`: for dyadic `p` in
{1/2, 1/4, 3/4, 1/8, 3/8, 1/16} it draws one word per lane, builds the
success-position mask with vector bitwise ops, and takes `@ctz(mask) / m` as
the failures before the first success; a word with no success (probability at
most `(3/4)^32`) draws another round. `VectorGeometric` returns
`failures + 1`.

## Measurements (same-period A/B)

| Row | Per-lane scalar draws | Dyadic kernel | Change |
| --- | --- | --- | --- |
| `alea vector geometric f64x4` (0.25) | 177.1 M | 294.7-339.0 M | +66-91% |
| `alea vector geometric-failures f64x4` (0.25) | new row | 319.7 M | coverage |

The trials checksum changes `8388208.000` -> `8396308.000` and the new
failures row records `6293501.000`; the stream change is versioned in
`reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: `dyadicGeometricFields`,
  `vectorGeometricDyadicFrom`, and the two vector samplers.
- `bench/throughput.zig`: the `alea vector geometric-failures f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the vector stream.
