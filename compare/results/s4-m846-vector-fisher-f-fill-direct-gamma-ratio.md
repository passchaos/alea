# S4-M846 VectorFisherF Reusable Fill Direct Cached Gamma Ratio Lanes

## S4-M1148 Supersession Note

S4-M1148 later replaces the former both-infinite FisherF deterministic edge with local `rand_distr`-compatible NaN output while preserving the corresponding ChiSquared/Gamma draw shape. The cached-Gamma direct-fill conclusions below remain relevant for finite FisherF paths; infinite-degree edge semantics now come from S4-M1148.

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
  finite-degree cached-Gamma ratio path directly; S4-M1148 now routes
  infinite-degree edges through the rand_distr-compatible NaN/draw-shape path.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorFisherF.sampleFrom` loops under identical seeds, proving output values
  and stream position stay aligned. Infinite-degree edge coverage is now
  superseded by S4-M1148's rand_distr-compatible NaN/draw-shape test.

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
fills while preserving finite-path stream shape; infinite-degree behavior is now
governed by S4-M1148. This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
