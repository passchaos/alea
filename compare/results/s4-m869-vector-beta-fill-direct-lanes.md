# S4-M869 VectorBeta Reusable Fill Direct Lane Sampling

## Gap

Reusable `VectorBeta.fillFrom` still routed every non-degenerate vector output
through `VectorBeta.sampleFrom`, adding a wrapper call before sampling each lane
from the cached scalar Beta sampler.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 represents `Beta` as a cached reusable sampler and draws
samples through its selected beta algorithm. Alea's vector Beta sampler
intentionally uses the cached scalar Beta sampler per lane to preserve exact
stream shape and beta method behavior, so reusable vector fills can inline the
lane loop directly while preserving the same stream as repeated
`VectorBeta.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorBeta.fillFrom` to keep the degenerate
  no-consume path and fill each vector by sampling its lanes directly from the
  cached scalar `Beta` sampler instead of calling `VectorBeta.sampleFrom` for
  every output.
- Focused tests compare f64x4 and f32x8 reusable vector fills with scalar
  `VectorBeta.sampleFrom` loops under identical seeds and cover an infinite-alpha
  degenerate no-consume path.

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
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M869 is closed for the current bar: reusable `VectorBeta.fillFrom` now avoids
per-vector `VectorBeta.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
