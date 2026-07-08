# S4-M860 VectorWeibull Reusable Fill Direct Open-Uniform Transform

## Gap

Scalar reusable `Weibull.fillFrom` already delegates to specialized bulk paths,
including the shape-one standard-exponential path. Reusable
`VectorWeibull.fillFrom` still routed every non-degenerate vector output through
`VectorWeibull.sampleFrom`, adding a wrapper call before drawing vector
open-uniform or standard-exponential values and applying the Weibull transform.

## Local `rand_distr` Baseline

Weibull sampling is an open-uniform draw followed by `scale * (-ln u)^(1/shape)`,
with a shape-one exponential specialization. Alea's vector Weibull sampler has
explicit vector transform helpers for these paths, so reusable vector fills can
call them directly while preserving the same stream as repeated
`VectorWeibull.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorWeibull.fillFrom` to keep the degenerate
  no-consume path, then dispatch directly to shape-one standard-exponential
  vector fills or generic open-uniform Weibull vector transforms.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorWeibull.sampleFrom` loops under identical seeds, prove shape-one
  stream-shape parity, and cover the degenerate no-consume path.

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
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M860 is closed for the current bar: reusable `VectorWeibull.fillFrom` now
avoids per-vector `VectorWeibull.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
