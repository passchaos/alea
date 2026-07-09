# S4-M845 FisherF Reusable Fill Direct Cached Gamma Ratio Loop

## S4-M1148 Supersession Note

S4-M1148 later replaces the former both-infinite FisherF deterministic edge with local `rand_distr`-compatible NaN output while preserving the corresponding ChiSquared/Gamma draw shape. The cached-Gamma direct-fill conclusions below remain relevant for finite FisherF paths; infinite-degree edge semantics now come from S4-M1148.

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
  finite-degree cached-Gamma ratio path directly; S4-M1148 now routes
  infinite-degree edges through the rand_distr-compatible NaN/draw-shape path.
- Focused tests compare f64 and f32 reusable fills with scalar
  `FisherF.sampleFrom` loops under identical seeds, proving output values and
  stream position stay aligned. Infinite-degree edge coverage is now superseded
  by S4-M1148's rand_distr-compatible NaN/draw-shape test.

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
preserving finite-path stream shape; infinite-degree behavior is now governed by
S4-M1148. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
