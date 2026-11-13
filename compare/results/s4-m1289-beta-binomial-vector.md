# S4-M1289 — Beta-binomial vector sampling

## Goal

Add the lane-wise vector API for the beta-binomial count distribution:

- `vectorBetaBinomial` / `vectorBetaBinomialFrom` /
  `vectorBetaBinomialChecked` / `vectorBetaBinomialCheckedFrom`.
- `fillVectorBetaBinomial` / `fillVectorBetaBinomialFrom` /
  `fillVectorBetaBinomialChecked` / `fillVectorBetaBinomialCheckedFrom`.
- `VectorBetaBinomial(VectorType)` reusable sampler.

The vector lanes are `u64` counts, matching the scalar sampler's integer
output.

## Implementation

- `VectorBetaBinomial(VectorType)` requires `u64` lanes and stores a scalar
  `BetaBinomial` sampler.
- Accessors expose the scalar moments (`expectedValue`, `varianceValue`),
  support bounds (`minValue`, `maxValue`), parameter accessors, and
  `pmf`/`cdf`/`quantile` diagnostics.
- `sample`/`sampleFrom` loop lanes in order, preserving the same stream shape
  as repeated scalar samples; `fill`/`fillFrom` loop over destination vectors.
- The eight free functions follow the existing vector-sampler pattern,
  including empty-destination early returns for checked fills.

## Tests added (1 new, total 836)

`VectorBetaBinomial samples, accessors, and lane parity work`:

- `@Vector(4, u64)` moments/support/PMF accessors for `n=20, α=2, β=3`.
- sample and two-vector fill range checks.
- invalid-parameter error for `init`.
- lane-by-lane stream parity between `VectorBetaBinomial(@Vector(4, u64))` and
  the scalar `BetaBinomial` sampler for the same engine seed.

## Validation

- `zig build test` passes: 836/836 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "VectorBetaBinomial"` passes.
- `docs/api-reference.md` updated for all 24 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1289 row added.

## Deviations and notes

- The vector path is lane-wise rather than a single true SIMD transform
  because the compound Beta+binomial draw is inherently sequential per lane;
  this matches the other rejection/compound vector samplers.
- The type intentionally restricts lanes to `u64` so no lossy narrowing is
  possible.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
