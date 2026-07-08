# S4-M861 VectorGumbel Reusable Fill Direct Open-Closed-Uniform Transform

## Gap

Scalar reusable `Gumbel.fillFrom` already delegates to the top-level bulk helper.
Reusable `VectorGumbel.fillFrom` still routed every non-degenerate vector output
through `VectorGumbel.sampleFrom`, adding a wrapper call before drawing vector
open-closed-uniform values and applying the Gumbel transform.

## Local `rand_distr` Baseline

Gumbel sampling is an open-closed-uniform draw followed by
`location - scale * ln(-ln(u))`. Alea's vector Gumbel sampler has an explicit
vector transform helper, so reusable vector fills can call that helper directly
while preserving the same stream as repeated `VectorGumbel.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorGumbel.fillFrom` to keep the degenerate
  no-consume path, then draw `Rng.vectorOpenClosedFrom(source, VectorType)` and
  call `gumbelFromOpenClosedUniformVector` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorGumbel.sampleFrom` loops under identical seeds, proving output values
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
toolingcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M861 is closed for the current bar: reusable `VectorGumbel.fillFrom` now
avoids per-vector `VectorGumbel.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
