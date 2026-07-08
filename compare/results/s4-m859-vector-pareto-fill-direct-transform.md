# S4-M859 VectorPareto Reusable Fill Direct Open-Uniform Transform

## Gap

Scalar reusable `Pareto.fillFrom` already delegates to the top-level bulk helper.
Reusable `VectorPareto.fillFrom` still routed every non-degenerate vector output
through `VectorPareto.sampleFrom`, adding a wrapper call before drawing vector
open-uniform values and applying the Pareto transform.

## Local `rand_distr` Baseline

Pareto sampling is an open-uniform draw followed by a reciprocal/power transform,
with a simpler reciprocal path when `shape == 1`. Alea's vector Pareto sampler
has explicit vector transform helpers for these paths, so reusable vector fills
can call them directly while preserving the same stream as repeated
`VectorPareto.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorPareto.fillFrom` to keep the degenerate
  no-consume path, then draw `Rng.vectorOpenFrom(source, VectorType)` and call
  either the shape-one reciprocal path or `paretoFromOpenUniformVector` for each
  output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorPareto.sampleFrom` loops under identical seeds, prove shape-one
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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M859 is closed for the current bar: reusable `VectorPareto.fillFrom` now
avoids per-vector `VectorPareto.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
