# S4-M1006 VectorBeta Sampler Facade Direct Paths

## Gap

Reusable `VectorBeta(VectorType).sample` and `VectorBeta(VectorType).fill` facade
helpers still routed through `sampleFrom` / `fillFrom` wrappers. S4-M1005 made the
scalar Beta facade paths direct; the vector sampler can now draw lanes from the
cached scalar Beta facade sampler directly while preserving vector lane stream
shape and point-mass behavior.

## Local `rand` Baseline

Local Rust `rand_distr` `Beta` reusable samplers sample directly from an RNG
reference. Alea's `VectorBeta` is a Zig-native lane convenience over a cached
scalar Beta sampler; facade calls should drive facade `Rng` lane-by-lane instead
of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `VectorBeta.sample` to handle point-mass
  degenerate output directly and otherwise fill lanes with cached scalar
  `Beta.sample(rng)` calls.
- `src/distributions.zig` updates `VectorBeta.fill` to handle degenerate buffers
  directly and otherwise fill each vector lane from cached scalar
  `Beta.sample(rng)`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level vector helpers.

## Validation

Focused VectorBeta tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate gamma helpers do not consume random stream"
1/2 distributions.test.degenerate gamma helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length distribution vector fills do not validate or consume random stream"
1/2 distributions.test.zero-length distribution vector fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1006 is closed for the current bar: reusable VectorBeta facade sample/fill
helpers now avoid direct-source wrapper aliases while preserving vector lane
stream shape, point-mass no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
