# S4-M862 VectorFrechet Reusable Fill Direct Open-Closed-Uniform Transform

## Gap

Scalar reusable `Frechet.fillFrom` already delegates to the top-level bulk helper.
Reusable `VectorFrechet.fillFrom` still routed every non-degenerate vector output
through `VectorFrechet.sampleFrom`, adding a wrapper call before drawing vector
open-closed-uniform values and applying the Frechet transform.

## Local `rand_distr` Baseline

Frechet sampling is an open-closed-uniform draw followed by an inverse-Gumbel
style transform, with a simpler shape-one path. Alea's vector Frechet sampler
has explicit vector transform helpers for these paths, so reusable vector fills
can call those helpers directly while preserving the same stream as repeated
`VectorFrechet.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorFrechet.fillFrom` to keep the degenerate
  no-consume path, then draw `Rng.vectorOpenClosedFrom(source, VectorType)` and
  call either `frechetShapeOneFromOpenClosedUniformVector` or
  `frechetFromOpenClosedUniformVector` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorFrechet.sampleFrom` loops under identical seeds, prove shape-one
  stream-shape parity, and cover degenerate and infinite-shape no-consume paths.

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
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M862 is closed for the current bar: reusable `VectorFrechet.fillFrom` now
avoids per-vector `VectorFrechet.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
