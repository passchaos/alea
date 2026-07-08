# S4-M845 FisherF Reusable Fill Direct Cached Gamma Ratio Loop

## Gap

Reusable `FisherF.fillFrom` still looped through `FisherF.sampleFrom` for every
non-degenerate output. `FisherF` stores cached numerator and denominator Gamma
samplers with normalized scales, so bulk fills can draw those two cached samplers
and divide directly, avoiding a FisherF wrapper call per output while preserving
exactly the same random stream shape.

## Local `rand_distr` Baseline

Local `rand_distr` implements Fisher F as the ratio of two chi-squared draws
scaled by the degree-of-freedom ratio. Alea stores equivalent cached Gamma
samplers for the normalized numerator and denominator, so the reusable fill can
express that composition directly in the fill loop.

## Implementation

- `src/distributions.zig` updates `FisherF.fillFrom` to keep the existing
  infinite-degrees point-mass no-consume path, then draw
  `self.numerator.sampleFrom(source) / self.denominator.sampleFrom(source)` for
  each output.
- Focused tests compare f64 and f32 reusable fills with scalar
  `FisherF.sampleFrom` loops under identical seeds, proving output values and
  stream position stay aligned. The focused test also covers the infinite-degrees
  point-mass no-consume path.

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
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M845 is closed for the current bar: reusable `FisherF.fillFrom` now avoids
per-output `FisherF.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and point-mass no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
