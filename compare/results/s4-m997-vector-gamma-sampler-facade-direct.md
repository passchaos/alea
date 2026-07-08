# S4-M997 VectorGamma Sampler Facade Direct Paths

## Gap

Reusable `VectorGamma(VectorType).sample` and `VectorGamma(VectorType).fill`
facade helpers still routed through `sampleFrom` / `fillFrom` wrappers. S4-M996
made reusable scalar Gamma facade sample/fill paths direct; the reusable vector
sampler can now execute degenerate, shape-one, and general per-lane Gamma sampling
directly through facade `Rng` while preserving vector lane stream shape.

## Local `rand` Baseline

Local Rust `rand_distr` `Gamma` reusable samplers sample directly from an RNG
reference. Alea's `VectorGamma` is a Zig-native lane convenience over cached
scalar Gamma samplers; facade calls should drive the facade `Rng` lane-by-lane
instead of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `VectorGamma.sample` to handle degenerate
  scale-zero output directly and otherwise fill lanes with cached scalar
  `Gamma.sample(rng)` calls.
- `src/distributions.zig` updates `VectorGamma.fill` to handle degenerate output,
  shape-one vector standard-exponential fills, and general lane sampling directly
  through facade `Rng` instead of delegating to `fillFrom`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and existing composition helpers.

## Validation

Focused VectorGamma tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
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
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M997 is closed for the current bar: reusable VectorGamma facade sample/fill
helpers now avoid direct-source wrapper aliases while preserving vector lane
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
