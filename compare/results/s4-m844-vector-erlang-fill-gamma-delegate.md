# S4-M844 VectorErlang Reusable Fill Delegates to VectorGamma Fill

## Gap

S4-M843 made scalar reusable `Erlang.fillFrom` delegate to the cached Gamma
sampler fill. Reusable `VectorErlang.fillFrom` still looped through
`VectorErlang.sampleFrom` for every non-degenerate vector output, missing the
shape-specific `VectorGamma.fillFrom` bulk paths, including shape-one
standard-vector-exponential staging.

## Local `rand_distr` Baseline

Local `rand_distr` exposes Gamma as the general family behind exponential and
integer-shape waiting-time distributions. Alea's vector Erlang sampler is a
Zig-native integer-shape wrapper over a cached Gamma sampler, so vector bulk
fills can compose through `VectorGamma.fillFrom` over that cached state while
preserving repeated-sample stream shape.

## Implementation

- `src/distributions.zig` updates `VectorErlang.fillFrom` to keep the scale-zero
  degenerate no-consume path, then delegate to `VectorGamma(VectorType)`
  constructed from the cached Gamma sampler.
- Focused tests compare reusable vector Erlang fills with equivalent
  `VectorGamma(shape, scale).fillFrom`, compare f32x8 fills with scalar
  `VectorErlang.sampleFrom` loops, and cover scale-zero no-consume behavior.

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
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M844 is closed for the current bar: reusable `VectorErlang.fillFrom` now
reuses the cached Gamma sampler through `VectorGamma.fillFrom` instead of routing
every output through `VectorErlang.sampleFrom`, preserving stream shape while
sharing vector Gamma optimized bulk cases. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
