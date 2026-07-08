# S4-M830 VectorBinomial Fill Direct Sampler Loop

## Gap

S4-M822 tightened scalar `Binomial.fillFrom` to call `binomialFrom` directly.
`VectorBinomial.fillFrom` still routed every vector output through
`VectorBinomial.sampleFrom`, adding a wrapper call before drawing each vector's
lanes.

## Local `rand_distr` Baseline

Vector binomial bulk workflows repeatedly draw scalar binomial samples into vector
lanes. Alea's reusable `VectorBinomial.fillFrom` should preserve the same stream
shape while drawing lanes directly with the underlying scalar sampler.

## Implementation

- `src/distributions.zig` updates `VectorBinomial.fillFrom` to call
  `binomialFrom(source, trials, p)` directly for each vector lane when the
  distribution is not degenerate.
- Focused tests compare direct vector fills with a manual scalar-lane
  `binomialFrom` loop under identical seeds, proving output values and stream
  position stay aligned.

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
roadmapcheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M830 is closed for the current bar: `VectorBinomial.fillFrom` now avoids
per-vector `VectorBinomial.sampleFrom` wrapper calls for ordinary parameters and
draws lanes with the underlying `binomialFrom` sampler directly while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
