# S4-M829 VectorNegativeBinomial Fill Direct Sampler Loop

## Gap

S4-M823 tightened scalar `NegativeBinomial.fillFrom` to call
`negativeBinomialFrom` directly. `VectorNegativeBinomial.fillFrom` still routed
every vector output through `VectorNegativeBinomial.sampleFrom`, adding a wrapper
call before drawing each vector's lanes.

## Local `rand_distr` Baseline

Vector negative-binomial bulk workflows repeatedly draw scalar negative-binomial
samples into vector lanes. Alea's reusable `VectorNegativeBinomial.fillFrom`
should preserve the same stream shape while drawing lanes directly with the
underlying scalar sampler.

## Implementation

- `src/distributions.zig` updates `VectorNegativeBinomial.fillFrom` to call
  `negativeBinomialFrom(source, successes, p)` directly for each vector lane when
  `p != 1`.
- Focused tests compare direct vector fills with a manual scalar-lane
  `negativeBinomialFrom` loop under identical seeds, proving output values and
  stream position stay aligned.

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
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M829 is closed for the current bar: `VectorNegativeBinomial.fillFrom` now
avoids per-vector `VectorNegativeBinomial.sampleFrom` wrapper calls for ordinary
parameters and draws lanes with the underlying `negativeBinomialFrom` sampler
directly while preserving stream shape. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
