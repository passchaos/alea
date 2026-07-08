# S4-M831 VectorBinomialPoissonApprox Fill Direct Sampler Loop

## Gap

S4-M830 tightened `VectorBinomial.fillFrom` to call `binomialFrom` directly per
lane. `VectorBinomialPoissonApprox.fillFrom` still routed every vector output
through `VectorBinomialPoissonApprox.sampleFrom`, adding a wrapper call before
drawing each vector's lanes.

## Local `rand_distr` Baseline

Vector binomial-approximation bulk workflows repeatedly draw scalar approximation
samples into vector lanes. Alea's reusable `VectorBinomialPoissonApprox.fillFrom`
should preserve the same stream shape while drawing lanes directly with the
underlying scalar approximation sampler.

## Implementation

- `src/distributions.zig` updates `VectorBinomialPoissonApprox.fillFrom` to call
  `binomialPoissonApproxFrom(source, trials, p)` directly for each vector lane
  when the distribution is not degenerate.
- Focused tests compare direct vector fills with a manual scalar-lane
  `binomialPoissonApproxFrom` loop under identical seeds, proving output values
  and stream position stay aligned.

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
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M831 is closed for the current bar: `VectorBinomialPoissonApprox.fillFrom` now
avoids per-vector `VectorBinomialPoissonApprox.sampleFrom` wrapper calls for
ordinary parameters and draws lanes with the underlying
`binomialPoissonApproxFrom` sampler directly while preserving stream shape. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
