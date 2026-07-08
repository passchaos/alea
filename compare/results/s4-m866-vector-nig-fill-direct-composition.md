# S4-M866 VectorNormalInverseGaussian Reusable Fill Direct Composition

## Gap

Scalar reusable `NormalInverseGaussian.fillFrom` already stages the embedded
inverse-Gaussian draw and then composes the final normal-inverse-Gaussian value.
Reusable `VectorNormalInverseGaussian.fillFrom` still routed every non-degenerate
vector output through `VectorNormalInverseGaussian.sampleFrom`, adding a wrapper
call before drawing the embedded inverse-Gaussian vector and final standard
normal vector.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 represents `NormalInverseGaussian` as a cached `beta`
plus an embedded `InverseGaussian`; sampling draws the embedded inverse-Gaussian
value and returns `beta * inv_gauss + sqrt(inv_gauss) * StandardNormal`. Alea's
vector sampler has the same composition, so reusable vector fills can draw the
embedded inverse-Gaussian normal/uniform vector pair and final standard-normal
vector directly while preserving the same stream as repeated
`VectorNormalInverseGaussian.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorNormalInverseGaussian.fillFrom` to keep
  the degenerate no-consume path, cache `inverse_mean` and `beta` locally, draw
  the embedded inverse-Gaussian vector through `inverseGaussianFromNormalVector`,
  then draw the final standard-normal vector and compose the result directly.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorNormalInverseGaussian.sampleFrom` loops under identical seeds and cover
  the infinite-alpha degenerate no-consume path.

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
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M866 is closed for the current bar: reusable
`VectorNormalInverseGaussian.fillFrom` now avoids per-vector
`VectorNormalInverseGaussian.sampleFrom` wrapper calls for non-degenerate fills
while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
