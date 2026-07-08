# S4-M858 VectorMaxwell Reusable Fill Direct Normal Triple Transform

## Gap

Reusable `VectorMaxwell.fillFrom` still routed every non-degenerate vector output
through `VectorMaxwell.sampleFrom`, adding a wrapper call before drawing three
vector normal values and applying the Maxwell norm transform.

## Local `rand_distr` Baseline

Maxwell sampling is a norm over three independent normal draws. Alea's vector
Maxwell sampler has an explicit vector normal-triple transform helper, so
reusable vector fills can call that helper directly while preserving the same
stream as repeated `VectorMaxwell.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorMaxwell.fillFrom` to keep the degenerate
  no-consume path, then draw three `vectorNormalFrom` values and call
  `maxwellFromNormalVectors` for each output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorMaxwell.sampleFrom` loops under identical seeds, proving output values
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
roadmapcheck ok
apicheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M858 is closed for the current bar: reusable `VectorMaxwell.fillFrom` now
avoids per-vector `VectorMaxwell.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
