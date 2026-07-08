# S4-M977 Vector Hypergeometric Facade Direct Paths

## Gap

Top-level and reusable `VectorHypergeometric` facade helpers still routed through
`From` wrappers. Scalar Hypergeometric facade sample/fill was made direct in
S4-M976, so vector facade helpers can validate once and dispatch directly to the
selected hypergeometric method through the facade `Rng` while preserving stream
shape.

## Local `rand` Baseline

Local Rust `rand_distr` hypergeometric workflows sample directly from an RNG
reference. Alea's vector Hypergeometric helpers are Zig-native lane-batch
extensions and should expose facade sample/fill methods that avoid direct-source
wrapper hops.

## Implementation

- `src/distributions.zig` updates top-level `vectorHypergeometric` and
  `vectorHypergeometricChecked` to construct `VectorHypergeometric` and call
  facade `sample` directly.
- `src/distributions.zig` updates top-level `fillVectorHypergeometric` and
  `fillVectorHypergeometricChecked` to construct `VectorHypergeometric` and call
  facade `fill` directly.
- `src/distributions.zig` updates reusable `VectorHypergeometric.sample` and
  `fill` to dispatch directly to constant, draw-loop, inverse-transform, or
  rejection-acceptance paths through the facade `Rng`.
- Focused tests cover vector hypergeometric stream shape, deterministic cases, and
  invalid-vector no-consume behavior.

## Validation

Focused vector Hypergeometric tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution vector helpers do not consume random stream"
1/2 distributions.test.invalid distribution vector helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M977 is closed for the current bar: vector Hypergeometric facade helpers now
avoid direct-source wrapper aliases while preserving method-specific stream shape
and checked validation behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
