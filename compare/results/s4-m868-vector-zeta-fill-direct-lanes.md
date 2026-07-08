# S4-M868 VectorZeta Reusable Fill Direct Lane Sampling

## Gap

Reusable `VectorZeta.fillFrom` still routed every non-degenerate vector output
through `VectorZeta.sampleFrom`, adding a wrapper call before sampling each lane
with the cached scalar Zeta rejection sampler.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 samples `Zeta` from a cached sampler using an
open-closed-uniform proposal and a uniform rejection check. Alea's vector Zeta
sampler intentionally uses the same cached scalar Zeta sampler per lane to
preserve exact stream shape and rejection behavior, so reusable vector fills can
inline the lane loop directly while preserving the same stream as repeated
`VectorZeta.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorZeta.fillFrom` to keep the degenerate
  no-consume path and fill each vector by sampling its lanes directly from the
  cached scalar `Zeta` sampler instead of calling `VectorZeta.sampleFrom` for
  every output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorZeta.sampleFrom` loops under identical seeds and cover the infinite-
  exponent degenerate no-consume path.

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
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M868 is closed for the current bar: reusable `VectorZeta.fillFrom` now avoids
per-vector `VectorZeta.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
