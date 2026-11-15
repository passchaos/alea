# S4-M1664 Vector Binomial Hoisted-CDF Fill

Date: 2026-11-16

## Change

The non-dyadic `VectorBinomial.fill`/`fillFrom` delegated every vector to
`sampleFrom`, which rebuilt the binomial CDF (one `pow` plus the pmf
recurrence) per vector. Refactored the inverse-CDF kernel into
`binomialCdfTable` + `vectorBinomialFromCdf`, and added a fill fast path that
builds the table once per call and reuses it for the whole slice. The table
arithmetic and per-vector uniform draws are unchanged, so the fill values are
identical to repeated `sampleFrom` (the fill-vs-loop tests pass).

## Measurements

| Row | Per-vector `sampleFrom` fill | Hoisted-CDF fill |
| --- | --- | --- |
| `alea fillVectorBinomial non-dyadic f64x4` (40, 0.4) | 22.6-23.2 M vectors/s (from the `alea vector binomial non-dyadic f64x4` row) | 81.4-82.5 M vectors/s |

The new row is stream-equivalent to the repeated-sample fill; the checksum is
stable across runs (`33550740.000`) but is seeded differently from the sample
row, so the two checksums are not comparable.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950), including the fill-vs-loop stream
  tests.

## Changed Files

- `src/distributions.zig`: `binomialCdfTable`, `vectorBinomialFromCdf`, and
  the hoisted fill path.
- `bench/throughput.zig`: the `alea fillVectorBinomial non-dyadic f64x4` row.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  fill speedup.
