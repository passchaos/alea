# S4-M863 VectorSkewNormal Reusable Fill Direct Normal Composition

## Gap

Scalar reusable `SkewNormal.fillFrom` already implements branch-specific direct
normal composition paths. Reusable `VectorSkewNormal.fillFrom` still routed every
non-degenerate vector output through `VectorSkewNormal.sampleFrom`, adding a
wrapper call before drawing standard-normal vectors and applying the skew-normal
composition.

## Local `rand_distr` Baseline

Skew-normal sampling is built from one or two standard-normal draws and a
shape-dependent composition. Alea's vector SkewNormal sampler has an explicit
vector composition helper, so reusable vector fills can call that helper directly
while preserving the same stream as repeated `VectorSkewNormal.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorSkewNormal.fillFrom` to keep the
  degenerate no-consume path, then draw vector standard-normal values and apply
  either the symmetric affine transform or `skewNormalFromStandardNormalVectors`.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorSkewNormal.sampleFrom` loops under identical seeds, prove symmetric and
  negative-shape stream-shape parity, and cover the degenerate no-consume path.

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
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M863 is closed for the current bar: reusable `VectorSkewNormal.fillFrom` now
avoids per-vector `VectorSkewNormal.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
