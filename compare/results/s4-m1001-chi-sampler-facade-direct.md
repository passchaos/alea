# S4-M1001 Chi Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `Chi` facade sample/fill helpers still routed through
`sampleFrom` / `fillFrom` wrappers. S4-M999 and S4-M1000 made ChiSquared reusable
and top-level facade paths direct; `Chi` is backed by cached ChiSquared samplers
and can dispatch through their facade sample/fill methods directly.

## Local `rand` Baseline

Local Rust `rand_distr` `Chi` composes ChiSquared-style sampling and samples from
the supplied RNG reference. Alea's scalar/vector reusable Chi facade helpers
should likewise drive facade `Rng` directly instead of bouncing through
direct-source aliases.

## Implementation

- `src/distributions.zig` updates `Chi(T).sample` and `Chi(T).fill` to call the
  cached ChiSquared sampler's facade `sample` / `fill` directly and then take
  square roots.
- `src/distributions.zig` updates `VectorChi(VectorType).sample` and
  `VectorChi(VectorType).fill` to construct a `VectorChiSquared` view over the
  cached ChiSquared sampler, call facade `sample` / `fill`, and take lane-wise
  square roots.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and existing composition helpers.

## Validation

Focused Chi/Gamma tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate gamma helpers do not consume random stream"
1/2 distributions.test.degenerate gamma helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length core continuous distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length core continuous distribution fills do not validate or consume random stream...OK
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
readmecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M1001 is closed for the current bar: reusable scalar/vector Chi facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
