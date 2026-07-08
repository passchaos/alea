# S4-M832 VectorHypergeometric Fill Direct Method Dispatch

## Gap

S4-M824 tightened scalar `Hypergeometric.fillFrom` to switch once and call method
samplers directly. `VectorHypergeometric.fillFrom` still routed every vector
output through `VectorHypergeometric.sampleFrom`, adding a wrapper call and method
dispatch before drawing each vector's lanes.

## Local `rand_distr` Baseline

Vector hypergeometric bulk workflows repeatedly draw scalar hypergeometric
samples into vector lanes using the selected method strategy. Alea's reusable
`VectorHypergeometric.fillFrom` should preserve the same stream shape while
switching once and drawing lanes directly with the selected method.

## Implementation

- `src/distributions.zig` updates `VectorHypergeometric.fillFrom` to switch once
  on the selected method and draw each vector lane directly with draw-loop,
  inverse-transform, or rejection-acceptance samplers.
- Focused tests compare direct vector fills with a manual scalar-lane
  `Hypergeometric.sampleFrom` loop under identical seeds, proving output values
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
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M832 is closed for the current bar: `VectorHypergeometric.fillFrom` now avoids
per-vector `VectorHypergeometric.sampleFrom` wrapper calls for non-constant
distributions and draws lanes with the selected method sampler directly while
preserving stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
