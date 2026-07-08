# S4-M855 VectorKumaraswamy Reusable Fill Direct Open-Uniform Transform

## Gap

Scalar reusable `Kumaraswamy.fillFrom` already implements specialized bulk paths
for degenerate, beta-one square-root, beta-one, alpha-one, and generic shapes.
Reusable `VectorKumaraswamy.fillFrom` still routed every non-degenerate vector
output through `VectorKumaraswamy.sampleFrom`, adding a wrapper call before
drawing vector open-uniform values and applying the Kumaraswamy transform.

## Local `rand_distr` Baseline

Kumaraswamy sampling is an open-uniform draw followed by a shape-dependent
closed-form transform. Alea's vector Kumaraswamy sampler has explicit vector
transform helpers for the generic, beta-one, alpha-one, and beta-one square-root
paths, so reusable vector fills can call those helpers directly while preserving
the same stream as repeated `VectorKumaraswamy.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorKumaraswamy.fillFrom` to keep the
  degenerate no-consume path, then draw `Rng.vectorOpenFrom(source, VectorType)`
  and dispatch once per output to the matching vector transform helper.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorKumaraswamy.sampleFrom` loops under identical seeds, prove beta-one and
  alpha-one stream-shape parity, and cover the degenerate no-consume path.

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
toolingcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M855 is closed for the current bar: reusable `VectorKumaraswamy.fillFrom` now
avoids per-vector `VectorKumaraswamy.sampleFrom` wrapper calls for
non-degenerate fills while preserving stream shape and degenerate no-consume
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
