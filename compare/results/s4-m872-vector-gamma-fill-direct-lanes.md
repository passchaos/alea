# S4-M872 VectorGamma Reusable Fill Direct Lane Sampling

## Gap

Reusable `VectorGamma.fillFrom` already had point-mass and shape-one standard-
exponential fast paths, but the remaining generic-shape path still routed every
vector output through `VectorGamma.sampleFrom`, adding a wrapper call before
sampling each lane from the cached scalar Gamma sampler.

## Local `rand_distr` Baseline

Local `rand_distr` uses reusable Gamma samplers with cached parameters and method
state. Alea's vector Gamma sampler intentionally uses the cached scalar Gamma
sampler per lane for the generic-shape path to preserve exact stream shape and
Marsaglia rejection behavior, so reusable vector fills can inline that lane loop
directly while preserving the same stream as repeated `VectorGamma.sampleFrom`
calls.

## Implementation

- `src/distributions.zig` updates `VectorGamma.fillFrom` to keep the degenerate
  no-consume path and the shape-one vector standard-exponential path, then fill
  generic-shape vectors by sampling each lane directly from the cached scalar
  `Gamma` sampler instead of calling `VectorGamma.sampleFrom` for every output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorGamma.sampleFrom` loops under identical seeds, while existing focused
  coverage still checks the shape-one fast path and degenerate no-consume path.

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
toolingcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M872 is closed for the current bar: reusable `VectorGamma.fillFrom` now avoids
per-vector `VectorGamma.sampleFrom` wrapper calls for generic-shape fills while
preserving stream shape and existing degenerate / shape-one fast paths. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
