# S4-M826 GeometricFailures Fill Direct Sampler Loop

## Gap

S4-M825 tightened `Geometric.fillFrom` to call the underlying sampler directly.
`GeometricFailures.fillFrom` still routed ordinary non-degenerate output through
`GeometricFailures.sampleFrom`, adding a wrapper call for every filled item before
reaching `geometricFailuresFrom`.

## Local `rand_distr` Baseline

Geometric-failures bulk workflows repeatedly draw from the same parameterized
sampler. Alea's reusable `GeometricFailures.fillFrom` should preserve the same
stream shape while calling the underlying sampler directly in the fill loop.

## Implementation

- `src/distributions.zig` updates `GeometricFailures.fillFrom` to call
  `geometricFailuresFrom(source, self.p)` directly for non-degenerate outputs.
- Focused tests compare direct fills with a scalar `geometricFailuresFrom` loop
  under identical seeds, proving output values and stream position stay aligned.

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
roadmapcheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M826 is closed for the current bar: `GeometricFailures.fillFrom` now avoids
per-item `GeometricFailures.sampleFrom` wrapper calls for ordinary parameters and
calls the underlying `geometricFailuresFrom` sampler directly while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
