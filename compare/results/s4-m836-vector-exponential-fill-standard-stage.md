# S4-M836 VectorExponential Reusable Fill Stages Standard Vectors Once

## Gap

S4-M835 made scalar reusable `Exponential.fillFrom` share the standard
exponential bulk helper and then scale in place. Reusable
`VectorExponential.fillFrom` still routed non-degenerate f32/f64 vector fills
through `fillVectorExponentialFrom(..., rate)`, which repeats parameterized
exponential dispatch instead of explicitly staging standard vector exponential
samples and scaling the backing lanes.

## Local `rand_distr` Baseline

Local `rand_distr` implements `Exp<F>` as `Exp1 * lambda_inverse`, with `Exp1`
being the optimized primitive. Alea's reusable vector exponential fill can use
the same decomposition for each vector lane in bulk form: fill standard vector
exponential values through the shared helper, then apply the cached inverse rate
while preserving the same sample stream as repeated `VectorExponential.sampleFrom`
calls.

## Implementation

- `src/distributions.zig` updates `VectorExponential.fillFrom` to keep the
  existing infinite-rate degenerate no-consume path, then for f32/f64 vector
  lanes call `fillVectorStandardExponentialFrom(source, VectorType, dest)` and
  scale the backing scalar lane slice in place by `self.inverse_rate` when
  needed. Non-f32/f64 float vectors keep the existing parameterized fallback.
- Focused tests compare reusable f32x8 fills with scalar
  `VectorExponential.sampleFrom` loops under identical seeds, prove the rate-1
  path matches `fillVectorStandardExponentialFrom`, and cover infinite-rate
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
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M836 is closed for the current bar: reusable `VectorExponential.fillFrom` now
avoids the parameterized vector-exponential fill wrapper for f32/f64
non-degenerate distributions while preserving stream shape and degenerate
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
