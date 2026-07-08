# S4-M999 ChiSquared Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `ChiSquared` facade sample/fill helpers still routed
through `sampleFrom` / `fillFrom` wrappers. S4-M996 through S4-M998 made reusable
and top-level Gamma facade paths direct; `ChiSquared` is backed by cached Gamma
samplers and can therefore dispatch through facade Gamma samplers directly.

## Local `rand` Baseline

Local Rust `rand_distr` `ChiSquared` composes Gamma-style sampling and samples
from the supplied RNG reference. Alea's scalar/vector reusable ChiSquared facade
helpers should likewise drive facade `Rng` directly instead of bouncing through
direct-source aliases.

## Implementation

- `src/distributions.zig` updates `ChiSquared(T).sample` and `ChiSquared(T).fill`
  to call the cached Gamma sampler's facade `sample` / `fill` directly.
- `src/distributions.zig` updates `VectorChiSquared(VectorType).sample` and
  `VectorChiSquared(VectorType).fill` to construct a `VectorGamma` view over the
  cached Gamma sampler and call facade `sample` / `fill` directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and existing composition helpers.

## Validation

Focused ChiSquared/Gamma tests:

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
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M999 is closed for the current bar: reusable scalar/vector ChiSquared facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
