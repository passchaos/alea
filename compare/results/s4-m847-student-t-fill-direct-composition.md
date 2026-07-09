# S4-M847 StudentT Reusable Fill Direct Normal/ChiSquared Composition

## S4-M1149 Supersession Note

S4-M1149 later replaces the former StudentT infinite-degree standard-normal limit extension with local `rand_distr`-compatible NaN output while preserving the corresponding StandardNormal plus ChiSquared/Gamma draw shape. The direct finite-degree composition conclusions below remain relevant; infinite-degree edge semantics now come from S4-M1149.

## Gap

Reusable `StudentT.fillFrom` still looped through `StudentT.sampleFrom` for every
finite-degree output. Since `StudentT` stores a cached `ChiSquared` sampler and
each sample is `StandardNormal * sqrt(dof / chi_squared)`, bulk fills can express
that composition directly in the loop and reuse the cached chi-square/Gamma bulk
paths added in earlier milestones.

## Local `rand_distr` Baseline

Local `rand_distr` implements StudentT as a standard-normal draw scaled by a
cached ChiSquared draw: `norm * sqrt(dof / chi.sample(rng))`. Alea now mirrors
that composition directly in reusable finite-degree fills while keeping the
then-current infinite-degree edge unchanged; S4-M1149 later supersedes that edge with rand_distr-compatible NaN/draw-shape semantics.

## Implementation

- `src/distributions.zig` updates `StudentT.fillFrom` to keep the existing
  S4-M1149-superseded infinite-degree edge path, then for finite degrees draw
  `Rng.normalFastFrom(source, T, 0, 1)` and
  `self.chi_squared_sampler.sampleFrom(source)` directly for each output.
- Focused tests compare f64 and f32 reusable fills with scalar
  `StudentT.sampleFrom` loops under identical seeds, proving output values and
  stream position stay aligned. Existing infinite-dof tests continue to cover
  the rand_distr-compatible NaN/draw-shape path.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M847 is closed for the current bar: reusable finite-degree `StudentT.fillFrom`
now avoids per-output `StudentT.sampleFrom` wrapper calls while preserving stream
shape and reusing cached ChiSquared/Gamma composition. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
