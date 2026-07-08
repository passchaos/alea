# S4-M854 VectorLogLogistic Reusable Fill Direct Open-Uniform Transform

## Gap

Scalar reusable `LogLogistic.fillFrom` already delegates to the top-level bulk
helper. Reusable `VectorLogLogistic.fillFrom` still routed every non-degenerate
vector output through `VectorLogLogistic.sampleFrom`, adding a wrapper call before
drawing vector open-uniform values and applying the LogLogistic transform.

## Local `rand_distr` Baseline

LogLogistic sampling is an open-uniform draw followed by a ratio/power transform,
with a simpler ratio path when `shape == 1`. Alea's vector LogLogistic sampler
has explicit vector transform helpers for both paths, so reusable vector fills
can call those helpers directly while preserving the same stream as repeated
`VectorLogLogistic.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorLogLogistic.fillFrom` to keep the
  degenerate no-consume path, then draw `Rng.vectorOpenFrom(source, VectorType)`
  and call either `logLogisticShapeOneFromOpenUniformVector` or
  `logLogisticFromOpenUniformVector` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorLogLogistic.sampleFrom` loops under identical seeds, prove shape-one
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
examplecheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M854 is closed for the current bar: reusable `VectorLogLogistic.fillFrom` now
avoids per-vector `VectorLogLogistic.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
