# S4-M827 VectorGeometric Fill Direct Sampler Loop

## Gap

S4-M825 tightened scalar `Geometric.fillFrom` to call `geometricFrom` directly.
`VectorGeometric.fillFrom` still routed every vector output through
`VectorGeometric.sampleFrom`, adding a wrapper call before drawing each vector's
lanes.

## Local `rand_distr` Baseline

Vector geometric bulk workflows repeatedly draw scalar geometric samples into
vector lanes. Alea's reusable `VectorGeometric.fillFrom` should preserve the same
stream shape while drawing lanes directly with the underlying scalar sampler.

## Implementation

- `src/distributions.zig` updates `VectorGeometric.fillFrom` to call
  `geometricFrom(source, p)` directly for each vector lane when `p != 1`.
- Focused tests compare direct vector fills with a manual scalar-lane
  `geometricFrom` loop under identical seeds, proving output values and stream
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
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M827 is closed for the current bar: `VectorGeometric.fillFrom` now avoids
per-vector `VectorGeometric.sampleFrom` wrapper calls for ordinary parameters and
draws lanes with the underlying `geometricFrom` sampler directly while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
