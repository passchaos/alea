# S4-M851 VectorCauchy Reusable Fill Direct Open-Uniform Transform

## Gap

Scalar reusable `Cauchy.fillFrom` already delegates to the top-level bulk helper.
Reusable `VectorCauchy.fillFrom` still routed every non-degenerate vector output
through `VectorCauchy.sampleFrom`, adding a wrapper call before drawing vector
open-uniform values and applying the Cauchy transform.

## Local `rand_distr` Baseline

Cauchy sampling is an open-uniform draw followed by a Cauchy transform. Alea's
vector Cauchy sampler has an explicit vector transform helper, so reusable
vector fills can call that helper directly after drawing vector open-uniform
values while preserving the same stream as repeated `VectorCauchy.sampleFrom`
calls.

## Implementation

- `src/distributions.zig` updates `VectorCauchy.fillFrom` to keep the degenerate
  no-consume path, then draw `Rng.vectorOpenFrom(source, VectorType)` and call
  `cauchyFromOpenUniformVector` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorCauchy.sampleFrom` loops under identical seeds, proving output values
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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M851 is closed for the current bar: reusable `VectorCauchy.fillFrom` now
avoids per-vector `VectorCauchy.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
