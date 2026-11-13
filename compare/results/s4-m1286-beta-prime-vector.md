# S4-M1286 — Beta prime vector/SIMD sampling

## Goal

Add the standard lane-wise vector API for the Beta prime distribution so
BetaPrime matches the vector surface of the other continuous families:

- `vectorBetaPrime` / `vectorBetaPrimeFrom` / `vectorBetaPrimeChecked` /
  `vectorBetaPrimeCheckedFrom`.
- `fillVectorBetaPrime` / `fillVectorBetaPrimeFrom` /
  `fillVectorBetaPrimeChecked` / `fillVectorBetaPrimeCheckedFrom`.
- `VectorBetaPrime(VectorType)` reusable sampler with accessors and
  `sample` / `sampleFrom` / `fill` / `fillFrom`.

## Implementation

- `VectorBetaPrime(VectorType)` stores a scalar `BetaPrime(Child)` sampler and
  fills each vector lane with an independent scalar draw.
- Accessors mirror the scalar sampler: `alphaValue`, `betaValue`,
  `expectedValue` (`?Child`), `varianceValue` (`?Child`), `modeValue`,
  `medianValue`, `minValue`, `maxValue`.
- `sample`/`sampleFrom` loop lanes in order, preserving the same stream shape
  as repeated scalar samples; `fill`/`fillFrom` loop over destination vectors.
- The free functions follow the existing `VectorBeta` pattern, including
  empty-destination early returns for the checked fill variants.

## Tests added (1 new, total 830)

`VectorBetaPrime samples, accessors, and lane parity work`:

- `BetaPrime(3,5)` moment/mode/median/support accessors through the vector
  wrapper.
- `@Vector(4, f64)` sample and two-vector fill positivity.
- invalid-parameter errors for `init` and `vectorBetaPrimeChecked`.
- lane-by-lane stream parity between `VectorBetaPrime(@Vector(4, f64))` and the
  scalar `BetaPrime(f64)` sampler for the same engine seed.
- `@Vector(8, f32)` support with finite positive lanes.

## Validation

- `zig build test` passes: 830/830 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "VectorBetaPrime"` passes.
- `docs/api-reference.md` updated for all 23 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1286 row added.

## Deviations and notes

- The vector path is lane-wise rather than a single true SIMD transform because
  Beta sampling is rejection-based; this matches `VectorBeta` and the other
  rejection-based vector samplers.
- No degenerate/point-mass fast path is needed: Beta prime has no point masses
  for finite positive parameters.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
