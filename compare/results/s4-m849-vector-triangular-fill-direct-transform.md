# S4-M849 VectorTriangular Reusable Fill Direct Uniform Transform

## Gap

Scalar reusable `Triangular.fillFrom` already delegates to the top-level bulk
helper. Reusable `VectorTriangular.fillFrom` still routed every non-degenerate
vector output through `VectorTriangular.sampleFrom`, adding a wrapper call before
drawing vector uniform values and applying the triangular transform.

## Local `rand_distr` Baseline

Local `rand_distr` triangular sampling is a uniform draw followed by a triangular
piecewise transform. Alea's vector triangular sampler has an explicit vector
transform helper, so reusable vector fills can call that helper directly after
drawing vector uniforms while preserving the same stream as repeated
`VectorTriangular.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorTriangular.fillFrom` to keep the
  degenerate no-consume path, then draw `Rng.vectorFrom(source, VectorType)` and
  call `triangularFromUniformVector` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorTriangular.sampleFrom` loops under identical seeds, proving output
  values and stream position stay aligned. The focused test also covers the
  degenerate no-consume path.

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
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M849 is closed for the current bar: reusable `VectorTriangular.fillFrom` now
avoids per-vector `VectorTriangular.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
