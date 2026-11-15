# S4-M1662 Vector Student-t Per-Lane Free Function and Vector Coverage Rows

Date: 2026-11-16

## New Coverage Rows

Added the remaining continuous vector rows with the scalar parameters:

| Row | Vector vectors/s | Scalar samples/s |
| --- | --- | --- |
| `alea vector gamma f64x4` (2, 3) | 61.1 M (244 M samples/s) | 169.2 M |
| `alea vector beta f64x4` (2, 5) | 20.7 M (83 M) | 86.5 M |
| `alea vector chi-squared f64x4` (4) | 61.0 M (244 M) | 166.7 M |
| `alea vector student-t f64x4` (10) | 21.7 M (87 M) | 196.9-197.0 M |
| `alea vector fisher-f f64x4` (5, 20) | 22.0 M (88 M) | 129.1 M |
| `alea vector erlang f64x4` (3, 2) | 63.0 M (252 M) | 219.9 M |

## Vector Student-t Adoption

`VectorStudentT` called the reusable `StudentT.sampleFrom` once per lane at
21.7 M vectors/s, while the scalar free-function row measured ~197 M
samples/s. Switched the per-lane calls to `studentTFrom`, which matches the
scalar row's draw shape: 21.7 -> 32.9-33.9 M vectors/s (+52-56%). The vector
checksum is unchanged (`-889.724`), so the stream is equivalent, and the
scalar row is unchanged in a bracketed A/B (medians 188.6 vs 186.6 M).

The same substitution for `VectorFisherF` (`fisherFFrom` per lane) measured
22.0 -> 18.8 M vectors/s (-15%) and was reverted.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `bench/throughput.zig`: six vector rows.
- `src/distributions.zig`: `VectorStudentT` per-lane `studentTFrom`.
- `compare/results/performance-triage.md`: records the adoption and the
  FisherF rejection.
