# S4-M856 VectorPowerFunction Reusable Fill Direct Range/Open-Uniform Transform

## Gap

Scalar reusable `PowerFunction.fillFrom` already implements specialized bulk
paths for degenerate, point-max, uniform, square-root, and generic shapes.
Reusable `VectorPowerFunction.fillFrom` still routed every non-degenerate vector
output through `VectorPowerFunction.sampleFrom`, adding a wrapper call before
selecting the vector transform path.

## Local `rand_distr` Baseline

Power-function sampling is a range/open-uniform draw followed by a
shape-dependent transform, with special point, uniform, and square-root cases.
Alea's vector PowerFunction sampler has explicit vector paths for these cases, so
reusable vector fills can dispatch to those paths directly while preserving the
same stream as repeated `VectorPowerFunction.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorPowerFunction.fillFrom` to keep the
  degenerate no-consume path, then dispatch directly to point-max, uniform range,
  square-root, or generic power-function transform paths.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorPowerFunction.sampleFrom` loops under identical seeds, prove uniform and
  square-root stream-shape parity, and cover degenerate plus point-max
  no-consume behavior.

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
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M856 is closed for the current bar: reusable `VectorPowerFunction.fillFrom`
now avoids per-vector `VectorPowerFunction.sampleFrom` wrapper calls for
non-degenerate fills while preserving stream shape and point-mass no-consume
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
