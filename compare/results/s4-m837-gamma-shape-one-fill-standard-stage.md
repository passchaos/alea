# S4-M837 Gamma Shape-One Reusable Fill Stages Standard Exponential Once

## Gap

Reusable `Gamma.fillFrom` still routed every non-degenerate output through
`Gamma.sampleFrom`. For the common `shape == 1` case, `Gamma.sampleFrom` is just
`scale * StandardExponential`, so repeated reusable fills paid an avoidable
wrapper/shape branch per item instead of using the shared standard-exponential
bulk helper and scaling once in place.

## Local `rand_distr` Baseline

Local `rand_distr` represents shape-one Gamma as `GammaRepr::One(Exp)`, where
`Exp` itself decomposes into `Exp1 * lambda_inverse`. Alea's reusable
shape-one Gamma fill can mirror that decomposition in bulk form: fill standard
exponential samples, then apply the cached Gamma scale while preserving the same
stream as repeated `Gamma.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Gamma.fillFrom` to keep the existing
  scale-zero degenerate no-consume path, then for `shape == 1` call
  `fillStandardExponentialFrom(source, T, dest)` and scale in place by
  `self.scale` when needed.
- Focused tests compare shape-one f64 fills with manually staged standard
  exponential output plus scaling, and compare shape-one f32 fills with scalar
  `Gamma.sampleFrom` loops under identical seeds, proving output values and
  stream position stay aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M837 is closed for the current bar: reusable `Gamma.fillFrom` now avoids
per-item `Gamma.sampleFrom` wrapper calls for shape-one non-degenerate fills
while preserving stream shape and scale-zero no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
