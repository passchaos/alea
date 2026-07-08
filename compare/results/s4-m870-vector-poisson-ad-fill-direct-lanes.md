# S4-M870 VectorPoissonAhrensDieter Reusable Fill Direct Lane Sampling

## Gap

Reusable `VectorPoissonAhrensDieter.fillFrom` still routed every vector output
through `VectorPoissonAhrensDieter.sampleFrom`, adding a wrapper call before
sampling each lane with the cached Ahrens-Dieter Poisson method.

## Local `rand_distr` Baseline

Local `rand_distr` uses reusable Poisson samplers with cached parameters and
samples through the selected method. Alea's dedicated vector Ahrens-Dieter helper
uses the cached scalar method per lane to preserve exact rejection-stream shape,
so reusable vector fills can inline that lane loop directly while preserving the
same stream as repeated `VectorPoissonAhrensDieter.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `VectorPoissonAhrensDieter.fillFrom` to fill
  each vector by sampling its lanes directly from the cached Ahrens-Dieter method
  instead of calling `VectorPoissonAhrensDieter.sampleFrom` for every output.
- Focused tests compare reusable vector fills with scalar
  `VectorPoissonAhrensDieter.sampleFrom` loops under identical seeds.

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
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M870 is closed for the current bar: reusable
`VectorPoissonAhrensDieter.fillFrom` now avoids per-vector
`VectorPoissonAhrensDieter.sampleFrom` wrapper calls for fills while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
