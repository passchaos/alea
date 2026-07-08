# S4-M848 VectorStudentT Reusable Fill Direct Normal/ChiSquared Lanes

## Gap

S4-M847 made scalar reusable `StudentT.fillFrom` draw the standard-normal and
cached ChiSquared components directly for finite degrees of freedom. Reusable
`VectorStudentT.fillFrom` still routed every non-infinite vector output through
`VectorStudentT.sampleFrom`, adding a wrapper call per vector before drawing each
lane.

## Local `rand_distr` Baseline

Local `rand_distr` implements StudentT as a standard-normal draw scaled by a
cached ChiSquared draw: `norm * sqrt(dof / chi.sample(rng))`. Alea now mirrors
that composition directly for each vector lane in reusable finite-degree fills,
while keeping the existing infinite-degree standard-normal vector path unchanged.

## Implementation

- `src/distributions.zig` updates `VectorStudentT.fillFrom` to keep the existing
  infinite-degree standard-normal vector fill path, then for finite degrees draw
  `Rng.normalFastFrom(source, Child, 0, 1)` and
  `self.sampler.chi_squared_sampler.sampleFrom(source)` directly for each lane.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorStudentT.sampleFrom` loops under identical seeds, proving output values
  and stream position stay aligned. Existing infinite-dof tests continue to cover
  the standard-normal vector stream-shape path.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M848 is closed for the current bar: reusable finite-degree
`VectorStudentT.fillFrom` now avoids per-vector `VectorStudentT.sampleFrom`
wrapper calls while preserving stream shape and reusing cached ChiSquared/Gamma
composition. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
