# S4-M864 VectorPert Reusable Fill Beta Delegate

## Gap

Scalar reusable `Pert.fillFrom` already preserves the beta-backed transform for
bulk fills. Reusable `VectorPert.fillFrom` still routed every non-degenerate
vector output through `VectorPert.sampleFrom`, adding a wrapper call before
constructing the beta sample and affine-mapping it into `[min, max]`.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 represents `Pert` as `{ min, range, beta: Beta<F> }`
and samples with `self.beta.sample(rng) * self.range + self.min`. Alea's vector
PERT sampler uses the same beta-backed decomposition in vector form, so reusable
vector fills can build one cached `VectorBeta` sampler and then apply the affine
range map to each vector output while preserving the same stream as repeated
`VectorPert.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorPert.fillFrom` to keep the degenerate
  no-consume path, construct a reusable `VectorBeta(VectorType)` from the cached
  PERT alpha/beta values, fill destination vectors through that beta sampler,
  and affine-map each vector with `min + range * beta_vec`.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorPert.sampleFrom` loops under identical seeds, prove shape-zero
  uniform-equivalent stream-shape parity, and cover both collapsed-support and
  infinite-shape degenerate no-consume paths.

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
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M864 is closed for the current bar: reusable `VectorPert.fillFrom` now avoids
per-vector `VectorPert.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
