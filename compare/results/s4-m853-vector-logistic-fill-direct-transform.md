# S4-M853 VectorLogistic Reusable Fill Direct Open-Uniform Transform

## Gap

Scalar reusable `Logistic.fillFrom` already delegates to the top-level bulk
helper. Reusable `VectorLogistic.fillFrom` still routed every non-degenerate
vector output through `VectorLogistic.sampleFrom`, adding a wrapper call before
drawing vector open-uniform values and applying the Logistic transform.

## Local `rand_distr` Baseline

Logistic sampling is an open-uniform draw followed by a logit transform. Alea's
vector Logistic sampler has an explicit vector transform helper, so reusable
vector fills can call that helper directly after drawing vector open-uniform
values while preserving the same stream as repeated `VectorLogistic.sampleFrom`
calls.

## Implementation

- `src/distributions.zig` updates `VectorLogistic.fillFrom` to keep the
  degenerate no-consume path, then draw `Rng.vectorOpenFrom(source, VectorType)`
  and call `logisticFromOpenUniformVector` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorLogistic.sampleFrom` loops under identical seeds, proving output values
  and stream position stay aligned. The focused test also covers the degenerate
  no-consume path.

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
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M853 is closed for the current bar: reusable `VectorLogistic.fillFrom` now
avoids per-vector `VectorLogistic.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
