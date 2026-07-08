# S4-M865 VectorInverseGaussian Reusable Fill Direct Composition

## Gap

Scalar reusable `InverseGaussian.fillFrom` already avoids a per-output sampler
wrapper by staging standard-normal draws and then applying the Michael-Schucany-
Haas acceptance transform in-place. Reusable `VectorInverseGaussian.fillFrom`
still routed every non-degenerate vector output through
`VectorInverseGaussian.sampleFrom`, adding a wrapper call before drawing vector
standard-normal and uniform values and applying the inverse-Gaussian transform.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 samples `InverseGaussian` by drawing one
`StandardNormal`, deriving the candidate value, then drawing one uniform value to
select between the candidate and reciprocal branch. Alea's vector sampler uses
that same composition in vector form, so reusable vector fills can draw the
normal/uniform vector pair directly and call the shared vector transform while
preserving the same stream as repeated `VectorInverseGaussian.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorInverseGaussian.fillFrom` to keep the
  degenerate no-consume path, cache `mean` and `shape` locally, then draw one
  standard-normal vector and one uniform vector per output and call
  `inverseGaussianFromNormalVector` directly.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorInverseGaussian.sampleFrom` loops under identical seeds and cover both
  zero-mean and infinite-shape degenerate no-consume paths.

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
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M865 is closed for the current bar: reusable
`VectorInverseGaussian.fillFrom` now avoids per-vector
`VectorInverseGaussian.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
