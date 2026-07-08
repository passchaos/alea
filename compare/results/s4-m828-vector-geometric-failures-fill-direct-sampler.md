# S4-M828 VectorGeometricFailures Fill Direct Sampler Loop

## Gap

S4-M826 tightened scalar `GeometricFailures.fillFrom` to call
`geometricFailuresFrom` directly. `VectorGeometricFailures.fillFrom` still routed
every vector output through `VectorGeometricFailures.sampleFrom`, adding a wrapper
call before drawing each vector's lanes.

## Local `rand_distr` Baseline

Vector geometric-failures bulk workflows repeatedly draw scalar geometric-failure
samples into vector lanes. Alea's reusable `VectorGeometricFailures.fillFrom`
should preserve the same stream shape while drawing lanes directly with the
underlying scalar sampler.

## Implementation

- `src/distributions.zig` updates `VectorGeometricFailures.fillFrom` to call
  `geometricFailuresFrom(source, p)` directly for each vector lane when `p != 1`.
- Focused tests compare direct vector fills with a manual scalar-lane
  `geometricFailuresFrom` loop under identical seeds, proving output values and
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
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M828 is closed for the current bar: `VectorGeometricFailures.fillFrom` now
avoids per-vector `VectorGeometricFailures.sampleFrom` wrapper calls for ordinary
parameters and draws lanes with the underlying `geometricFailuresFrom` sampler
directly while preserving stream shape. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
