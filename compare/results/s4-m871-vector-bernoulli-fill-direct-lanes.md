# S4-M871 VectorBernoulli Reusable Fill Direct Lane Sampling

## Gap

Reusable `VectorBernoulli.fillFrom` already had no-consume point-mass paths and
fast vector chance paths for common probabilities, but the remaining probability
values still routed every vector output through `VectorBernoulli.sampleFrom`,
adding a wrapper call before drawing one random word per lane and comparing it
with the cached integer threshold.

## Local `rand` Baseline

Local `rand` Bernoulli sampling is a cached-threshold comparison against random
bits. Alea's vector Bernoulli sampler uses the same threshold-comparison shape
per lane for generic probabilities, so reusable vector fills can inline that lane
loop directly while preserving the same stream as repeated
`VectorBernoulli.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorBernoulli.fillFrom` to keep the existing
  point-mass and 1/2 and 1/4 vector chance paths, then fill each vector by drawing
  one raw word per lane and comparing against the cached threshold instead of
  calling `VectorBernoulli.sampleFrom` for every output.
- Focused tests compare reusable vector fills with `VectorBernoulli.sampleFrom`
  loops for both the 1/4 fast path and a 1/3 generic-threshold path under
  identical seeds.

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
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M871 is closed for the current bar: reusable `VectorBernoulli.fillFrom` now
avoids per-vector `VectorBernoulli.sampleFrom` wrapper calls for generic
probability fills while preserving stream shape and existing no-consume / fast
paths. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
