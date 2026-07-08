# S4-M838 VectorGamma Shape-One Reusable Fill Stages Standard Exponential Vectors Once

## Gap

S4-M837 made scalar reusable `Gamma.fillFrom` share the standard exponential
bulk helper for the shape-one case. Reusable `VectorGamma.fillFrom` still routed
every non-degenerate vector output through `VectorGamma.sampleFrom`, adding a
wrapper call and Gamma shape dispatch for each vector even when each lane is just
`scale * StandardExponential`.

## Local `rand_distr` Baseline

Local `rand_distr` represents shape-one Gamma as `GammaRepr::One(Exp)`, where
`Exp` decomposes into `Exp1 * lambda_inverse`. Alea's reusable vector Gamma fill
can apply that same decomposition for f32/f64 lanes in bulk form: fill standard
vector exponential samples, then scale the backing lanes while preserving the
same stream as repeated `VectorGamma.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorGamma.fillFrom` to keep the existing
  scale-zero degenerate no-consume path, then for f32/f64 `shape == 1` call
  `fillVectorStandardExponentialFrom(source, VectorType, dest)` and scale the
  backing scalar lane slice by `self.sampler.scale` when needed. Other float
  vector lane types keep the existing generic sample loop.
- Focused tests compare shape-one f64x4 fills with manually staged standard
  vector exponential output plus scalar-lane scaling, and compare shape-one f32x8
  fills with scalar `VectorGamma.sampleFrom` loops under identical seeds, proving
  output values and stream position stay aligned.

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

S4-M838 is closed for the current bar: reusable `VectorGamma.fillFrom` now avoids
per-vector `VectorGamma.sampleFrom` wrapper calls for shape-one f32/f64
non-degenerate fills while preserving stream shape and scale-zero no-consume
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
