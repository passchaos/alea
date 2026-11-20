# S4-M1860 Vector Cos Polynomial in the Von Mises Vector Kernel

Date: 2026-11-20

## Gap

`vonMisesVectorFrom` evaluates the Best-Fisher proposal with a vector
`@cos(pi * ua)` in every rejection iteration. Vector `@cos` costs about
9.9 ns per f64x4 vector on this host, while a range-reduced polynomial
costs about 4.8 ns, so the trig is a measurable share of the 7.1M
vectors/s row.

## Change

The f64x4 kernel now evaluates `cos` through a degree-8 minimax polynomial
over `[0, pi/2]` (worst absolute error 3.3e-16) with the full-turn
reduction `t = min(theta, pi - theta)` and a sign select for
`theta > pi/2`. The f32x8 path keeps libm `@cos`, so its stream is
unchanged; the f64x4 `VectorVonMises` stream is a versioned bulk change
recorded in `reproducibility-matrix.md`.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216 "vector von mises"`), four
alternating pairs. Every candidate run is above every baseline run:

| Row | Baseline (M vectors/s) | Candidate (M vectors/s) |
| --- | --- | --- |
| `alea vector von mises f64x4` | 7.1, 7.1, 6.9, 7.1 | 7.7, 7.8, 7.3, 7.9 |

Medians: 7.1M -> 7.75M (about +9%). The checksum moves
`13426811416932291154` -> `13426811416935381980`, the expected versioned
low-bit change. The `vector von mises-fisher` row is unchanged within noise
(it does not use this kernel's `@cos`).

## Accuracy

- The polynomial's worst absolute `cos` error over `[0, pi/2]` is
  3.3e-16 (Chebyshev fit verified over 200k points); a 2M-point sweep over
  the full-turn range `[0, pi]` measures a worst error of 3.46e-16 at the
  `pi/2` fold, so the proposal density and acceptance probability move by
  about 1e-16.
- The `VectorVonMises` moment tests (mean direction and concentration at
  `kappa = 5`, the `kappa = 0` uniform case, and the f32x8 path) pass.
- Full tests 996/996, distcheck/statcheck/doccheck pass.

## Next Bar

The same polynomial could replace the `cos`/`sin` pairs in
`vectorVonMisesFisherFrom`, `vectorWatsonFrom`, `vectorBinghamFrom`, and
`vectorKentFrom`; those rows are dominated by Bessel/ACG work, so the
expected gain is smaller than the von Mises row's. The 1e9 long run
continues in the background as the next statistical bar.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.
