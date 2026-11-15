# S4-M1618 Scalar-Per-Lane Vector Inverse-CDF Sampling

Date: 2026-11-15

## New Rows

The Pareto, Weibull, Gumbel, and Fréchet vector samplers had no benchmark
rows. Added, matching the scalar row parameters:

- `alea vector pareto f64x4` (`VectorPareto(V4).init(2, 3)`),
- `alea vector weibull f64x4` (`VectorWeibull(V4).init(2, 1.5)`),
- `alea vector gumbel f64x4` (`VectorGumbel(V4).init(0, 1)`),
- `alea vector frechet f64x4` (`VectorFrechet(V4).init(0, 1, 3)`).

Packed-path baselines in the same machine period: Pareto 43.6 M, Weibull
18.6 M, Gumbel 28.1 M, Fréchet 18.2 M vectors/s.

## Probe And Adoption

The scalar samplers already use the fast `Exp(1)` kernel (S4-M1387), while the
vector samplers still drew a packed uniform and paid per-lane
`log`/`exp` transforms. Replaced each `Vector*.sampleFrom` with the scalar
point function once per lane (the S4-M1586/S4-M1616 pattern), made
`sample`/`fill`/`fillFrom` delegate, and removed the now-unused packed helpers
(`paretoFromOpenUniformVector`, `weibullFromOpenUniformVector`,
`gumbelFromOpenClosedUniformVector`, `frechetFromOpenClosedUniformVector`,
`frechetShapeOneFromOpenClosedUniformVector`).

| Row | Packed uniform | Scalar per lane | Vector checksum |
| --- | --- | --- | --- |
| `alea vector pareto f64x4` | 43.6 M | 93.4-95.2 M (+114-118%) | `6291651.956` -> `6289931.432` |
| `alea vector weibull f64x4` | 18.6 M | 19.1-19.5 M (+3-5%) | `3783676.746` -> `3788945.026` |
| `alea vector gumbel f64x4` | 28.1 M | 44.1-44.4 M (+57-58%) | `1208595.488` -> `1212786.943` |
| `alea vector frechet f64x4` | 18.2 M | 19.0-19.3 M (+4-6%) | `2841795.403` -> `2838534.301` |

The scalar rows stay inside the run-to-run band (Pareto 343-380 M, Weibull
77-80 M, Gumbel 174-181 M in the bracketed A/B, Fréchet 77-79 M) and their
checksums are unchanged (`393674.511`, `236542.767`, `75920.302`,
`177234.872`). The Gumbel scalar row was re-measured in a bracketed A/B after
one noisy probe sample (159.9 M); the probe median was 178.3 M against a
174.8 M baseline median, so there is no layout regression.

## Stream Shape

The vector helpers now consume four scalar `Exp(1)` draws per vector instead
of one packed uniform, so the infinite-scale stream-shape test reference was
updated to consume one scalar exponential per lane. The change is versioned in
`reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950), including the updated infinite-scale
  Pareto/Weibull stream-shape test.

## Changed Files

- `bench/throughput.zig`: four vector rows plus the shared
  `benchVectorDistribution` helper.
- `src/distributions.zig`: scalar-per-lane `VectorPareto`, `VectorWeibull`,
  `VectorGumbel`, and `VectorFrechet`; dead packed helpers removed; stream
  shape test reference updated.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the vector stream
  changes.
