# S4-M825 Geometric Fill Direct Sampler Loop

## Gap

`Geometric.fillFrom` handled the degenerate `p == 1` case directly, but for
ordinary parameters it still routed every output through `Geometric.sampleFrom`
before reaching the underlying `geometricFrom` sampler.

## Local `rand_distr` Baseline

Geometric bulk workflows repeatedly draw from the same parameterized geometric
sampler. Alea's reusable `Geometric.fillFrom` should preserve the same stream
shape while calling the underlying sampler directly in the fill loop.

## Implementation

- `src/distributions.zig` updates `Geometric.fillFrom` to call
  `geometricFrom(source, self.p)` directly for non-degenerate outputs.
- Focused tests compare direct fills with a scalar `geometricFrom` loop under
  identical seeds, proving output values and stream position stay aligned.

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
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M825 is closed for the current bar: `Geometric.fillFrom` now avoids per-item
`Geometric.sampleFrom` wrapper calls for ordinary parameters and calls the
underlying `geometricFrom` sampler directly while preserving stream shape. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
