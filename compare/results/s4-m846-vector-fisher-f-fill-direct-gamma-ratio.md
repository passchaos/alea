# S4-M846 VectorFisherF Reusable Fill Direct Cached Gamma Ratio Lanes

## Gap

S4-M845 made scalar reusable `FisherF.fillFrom` draw cached numerator and
denominator Gamma samplers directly. Reusable `VectorFisherF.fillFrom` still
looped through `VectorFisherF.sampleFrom` for every non-degenerate vector output,
adding a wrapper call and FisherF branch per vector before drawing each lane.

## Local `rand_distr` Baseline

Local `rand_distr` implements Fisher F as the ratio of two chi-squared draws
scaled by the degree-of-freedom ratio. Alea stores equivalent cached Gamma
samplers for the normalized numerator and denominator; vector fills can express
that same composition lane-by-lane directly while preserving the repeated
`VectorFisherF.sampleFrom` stream shape.

## Implementation

- `src/distributions.zig` updates `VectorFisherF.fillFrom` to keep the existing
  infinite-degrees point-mass no-consume path, then for each vector lane draw
  `self.sampler.numerator.sampleFrom(source) /
  self.sampler.denominator.sampleFrom(source)` directly.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorFisherF.sampleFrom` loops under identical seeds, proving output values
  and stream position stay aligned. The focused test also covers the
  infinite-degrees point-mass no-consume path.

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
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M846 is closed for the current bar: reusable `VectorFisherF.fillFrom` now
avoids per-vector `VectorFisherF.sampleFrom` wrapper calls for non-degenerate
fills while preserving stream shape and point-mass no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
