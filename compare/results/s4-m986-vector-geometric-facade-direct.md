# S4-M986 Vector Geometric Facade Direct Paths

## Gap

Vector `Geometric` and `GeometricFailures` top-level helpers and reusable facade
sample/fill methods still routed through `From` wrappers. S4-M985 made the scalar
facade paths direct, so the vector facade helpers can construct reusable vector
samplers once and call direct facade sample/fill methods while preserving vector
lane stream shape and zero-length checked-fill behavior.

## Local `rand` Baseline

Local Rust `rand_distr 0.6.0` exposes `Geometric` as a failure-count sampler via
`Distribution::sample(&mut rng)`. Alea keeps Zig-native one-based vector
`VectorGeometric` trial-count semantics and maps the Rust failure-count workflow
to `VectorGeometricFailures`; both vector facade samplers should draw directly
from facade `Rng` lane-by-lane instead of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `vectorGeometric`, `vectorGeometricChecked`,
  `fillVectorGeometric`, and `fillVectorGeometricChecked` to construct
  `VectorGeometric` once and call facade `sample` / `fill` directly.
- `src/distributions.zig` updates `vectorGeometricFailures`,
  `vectorGeometricFailuresChecked`, `fillVectorGeometricFailures`, and
  `fillVectorGeometricFailuresChecked` to construct `VectorGeometricFailures`
  once and call facade `sample` / `fill` directly.
- Reusable `VectorGeometric.sample`, `VectorGeometric.fill`,
  `VectorGeometricFailures.sample`, and `VectorGeometricFailures.fill` now execute
  degenerate `p == 1` fast paths and inverse-CDF lane loops directly through
  facade `Rng` instead of delegating to direct-source wrappers.
- Checked fill facades keep the existing zero-length fast path so empty
  destinations neither validate `p` nor consume random input.

## Validation

Focused vector Geometric tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution vector helpers do not consume random stream"
1/2 distributions.test.invalid distribution vector helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length distribution vector fills do not validate or consume random stream"
1/2 distributions.test.zero-length distribution vector fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate discrete distribution helpers do not consume random stream"
1/2 distributions.test.degenerate discrete distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M986 is closed for the current bar: vector Geometric and GeometricFailures
facade helpers now avoid direct-source wrapper aliases while preserving vector
lane stream shape, degenerate no-consume behavior, checked invalid-parameter
behavior, and zero-length checked fill semantics. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
