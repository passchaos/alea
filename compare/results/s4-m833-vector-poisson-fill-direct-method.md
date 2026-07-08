# S4-M833 VectorPoisson Fill Direct Method Dispatch

## Gap

`Poisson.fillFrom` already switches once and calls method samplers directly.
`VectorPoisson.fillFrom` still routed every vector output through
`VectorPoisson.sampleFrom`, adding a wrapper call and method dispatch before
drawing each vector's lanes.

## Local `rand_distr` Baseline

Vector Poisson bulk workflows repeatedly draw scalar Poisson samples into vector
lanes using the selected method strategy. Alea's reusable `VectorPoisson.fillFrom`
should preserve the same stream shape while switching once and drawing lanes
directly with the selected method.

## Implementation

- `src/distributions.zig` updates `VectorPoisson.fillFrom` to switch once on the
  selected method and draw each vector lane directly with product or
  Ahrens-Dieter samplers, while preserving zero-lambda memset behavior.
- Focused tests compare direct vector fills with a manual scalar-lane Poisson
  loop under identical seeds, proving output values and stream position stay
  aligned.

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
readmecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M833 is closed for the current bar: `VectorPoisson.fillFrom` now avoids
per-vector `VectorPoisson.sampleFrom` wrapper calls for non-zero distributions and
draws lanes with the selected method sampler directly while preserving stream
shape. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
