# S4-M1636 Vectorized Dyadic Binomial Kernel

Date: 2026-11-15

## Change

`VectorBinomial` previously ran the scalar reusable sampler once per lane
(5.3-5.7 M vectors/s = 21-23 M samples/s for trials=40, p=0.25). Added
`vectorBinomialDyadicFrom`: for dyadic `p` with `trials <= 64` it draws one
word per lane per round and evaluates the SWAR masks with vector bitwise ops
and `@popCount`, so a 40-trial sample costs two vector rounds. `sample`,
`sampleFrom`, `fill`, and `fillFrom` share the path, with the non-dyadic
fallback still per lane.

| Row | Per-lane scalar draws | Vector dyadic kernel | Change |
| --- | --- | --- | --- |
| `alea vector binomial f64x4` (40, 0.25) | 5.3-5.7 M | 302.4-375.2 M | ~57-70x |

The vector checksum changes `20975096.000` -> `20963148.000` (vector-packed
draws instead of per-lane scalar draws) and is versioned in
`reproducibility-matrix.md`. The scalar `Binomial` sampler is unchanged.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: `vectorBinomialDyadicFrom` and the `VectorBinomial`
  sampling methods.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the vector stream.
